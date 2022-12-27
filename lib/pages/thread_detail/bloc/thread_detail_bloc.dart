import 'dart:collection';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:collection/src/iterable_extensions.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/pages/base/base_bloc.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/exceptions.dart';
import 'package:flutter_chan_viewer/utils/extensions.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

import 'thread_detail_event.dart';
import 'thread_detail_state.dart';

class ThreadDetailBloc extends BaseBloc<ChanEvent, ChanState> {
  final logger = Logger();
  final ChanRepository _repository = getIt<ChanRepository>();
  final ChanStorage _chanStorage = getIt<ChanStorage>();
  final Preferences _preferences = getIt<Preferences>();

  final String _boardId;
  final int _threadId;
  final bool? _showDownloadsOnly;
  bool? _catalogMode;
  ThreadDetailModel? _threadDetailModel;
  List<ThreadItem> customThreads = [];

  ReceivePort _port = ReceivePort();

  CacheDirective get cacheDirective => CacheDirective(_boardId, _threadId);

  ThreadDetailBloc(this._boardId, this._threadId, this._showDownloadsOnly) : super(ChanStateLoading()) {
    on<ChanEventInitBloc>((event, emit) async {
      emit(ChanStateLoading());

      if (_catalogMode == null) {
        _catalogMode = _preferences.getBool(Preferences.KEY_THREAD_CATALOG_MODE, def: false);
      }
      customThreads = await _repository.getCustomThreads();

      IsolateNameServer.registerPortWithName(_port.sendPort, Constants.downloaderPortName);
      _port.listen((dynamic data) {
        String postId = data[0];
        int progress = data[1];
        logger.d("Download progress: $postId - $progress");
      });

      add(ChanEventFetchData());
    });

    on<ChanEventFetchData>((event, emit) async {
      emit(ChanStateLoading());

      if (_showDownloadsOnly ?? false) {
        DownloadFolderInfo folderInfo = _chanStorage.getThreadDownloadFolderInfo(cacheDirective);
        _threadDetailModel = ThreadDetailModel.fromFolderInfo(folderInfo);
        emit(buildContentState(lazyLoading: false));
        return;
      }

      _threadDetailModel = await _repository.fetchCachedThreadDetail(_boardId, _threadId);
      if (_threadDetailModel != null && _threadDetailModel!.visiblePosts.isNotNullNorEmpty) {
        emit(buildContentState(lazyLoading: true, event: ThreadDetailSingleEvent.SCROLL_TO_SELECTED));
      }

      try {
        ThreadDetailModel remoteThread = await _repository.fetchRemoteThreadDetail(_boardId, _threadId, false);

        var connectivityResult = await (Connectivity().checkConnectivity());
        if (remoteThread.isFavorite && connectivityResult == ConnectivityResult.wifi) {
          _repository.downloadAllMedia(remoteThread);
        }

        if (_threadDetailModel!.thread.lastSeenPostIndex < remoteThread.thread.replies) {
          ThreadItem? updatedThread = await _repository
              .updateThread(remoteThread.thread.copyWith(lastSeenPostIndex: remoteThread.thread.replies));
          _threadDetailModel = remoteThread.copyWith(thread: updatedThread);
        } else {
          _threadDetailModel = remoteThread;
        }
        emit(buildContentState(lazyLoading: false));
      } catch (e) {
        if (e is HttpException || e is SocketException) {
          emit(buildContentState(event: ChanSingleEvent.SHOW_OFFLINE));
        } else {
          rethrow;
        }
      }
    });

    on<ThreadDetailEventToggleFavorite>((event, emit) async {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      if (statuses.values.any((status) => status.isGranted == false)) {
        emit(ChanStateError("This feature requires permission to access storage"));
        return;
      }

      if (_threadDetailModel?.isFavorite ?? false) {
        if (event.confirmed) {
          await _repository.removeThreadFromFavorites(_threadDetailModel!);
          emit(buildContentState(event: ChanSingleEvent.CLOSE_PAGE));
        } else {
          emit(buildContentState(event: ThreadDetailSingleEvent.SHOW_UNSTAR_WARNING));
        }
      } else {
        emit(ChanStateLoading());

        ThreadItem? updatedThread = await _repository.addThreadToFavorites(_threadDetailModel!);
        _threadDetailModel = _threadDetailModel!.copyWith(thread: updatedThread);
        emit(buildContentState(lazyLoading: false));
      }
    });

    on<ThreadDetailEventToggleCatalogMode>((event, emit) {
      emit(ChanStateLoading());
      _catalogMode = !_catalogMode!;
      _preferences.setBool(Preferences.KEY_THREAD_CATALOG_MODE, _catalogMode!);
      emit(buildContentState(event: ThreadDetailSingleEvent.SCROLL_TO_SELECTED));
    });

    on<ThreadDetailEventOnPostSelected>((event, emit) async {
      int newPostId = event.postId;
      _threadDetailModel =
          _threadDetailModel!.copyWith(thread: _threadDetailModel!.thread.copyWith(selectedPostId: newPostId));
      await _repository.updateThread(_threadDetailModel!.thread);

      emit(buildContentState(event: ThreadDetailSingleEvent.SCROLL_TO_SELECTED));
    });

    on<ThreadDetailEventOnLinkClicked>((event, emit) async {
      int postId = ChanUtil.getPostIdFromUrl(event.url);
      if (postId > 0) {
        add(ThreadDetailEventOnPostSelected(postId));
      }
    });

    on<ThreadDetailEventOnReplyClicked>((event, emit) async {
      PostItem? post = _threadDetailModel!.findPostById(event.postId);
      if (post != null) {
        _threadDetailModel =
            _threadDetailModel!.copyWith(thread: _threadDetailModel!.thread.copyWith(selectedPostId: post.postId));
        await _repository.updateThread(_threadDetailModel!.thread);
      }

      emit(buildContentState(event: ThreadDetailSingleEvent.SCROLL_TO_SELECTED));
    });

    on<ThreadDetailEventHidePost>((event, emit) async {
      PostItem post = _threadDetailModel!.findPostById(event.postId)!.copyWith(isHidden: true);
      await _repository.updatePost(post);

      if (_threadDetailModel!.selectedPostIndex == event.postId) {
        int? newSelectedPostId = -1;
        for (int i = 0; i < _threadDetailModel!.allPosts.length; i++) {
          int dilatation = (i ~/ 2) + 1;
          int orientation = i % 2;
          int diff = orientation == 0 ? -dilatation : dilatation;
          int newSelectedPostIndex =
              (_threadDetailModel!.selectedPostIndex + diff) % _threadDetailModel!.allPosts.length;
          PostItem newSelectedPost = _threadDetailModel!.allPosts[newSelectedPostIndex];
          if (!newSelectedPost.isHidden) {
            newSelectedPostId = newSelectedPost.postId;
            break;
          }
        }
        _threadDetailModel = _threadDetailModel!
            .copyWith(thread: _threadDetailModel!.thread.copyWith(selectedPostId: newSelectedPostId));
        await _repository.updateThread(_threadDetailModel!.thread);
      }

      _threadDetailModel = await _repository.fetchCachedThreadDetail(_boardId, _threadId);
      emit(buildContentState(lazyLoading: false, event: ThreadDetailSingleEvent.SCROLL_TO_SELECTED));
    });

    on<ThreadDetailEventCreateNewCollection>((event, emit) async {
      await _repository.createCustomThread(event.name);
      customThreads = await _repository.getCustomThreads();
      emit(buildContentState(event: ThreadDetailSingleEvent.SHOW_COLLECTIONS_DIALOG));
    });

    on<ThreadDetailEventAddPostToCollection>((event, emit) async {
      ThreadItem thread = customThreads.where((element) => element.subtitle == event.name).firstOrNull!;
      PostItem post = _threadDetailModel!.findPostById(event.postId)!;
      await _repository.addPostToCustomThread(post, thread);
      emit(buildContentState(event: ThreadDetailSingleEvent.SHOW_POST_ADDED_TO_COLLECTION_SUCCESS));
    });

    on<ThreadDetailEventDeleteCollection>((event, emit) async {
      await _repository.deleteCustomThread(_threadDetailModel!);
      emit(buildContentState(event: ChanSingleEvent.CLOSE_PAGE));
    });
  }

  @override
  Future<void> close() {
    IsolateNameServer.removePortNameMapping(Constants.downloaderPortName);
    return super.close();
  }

  @override
  ThreadDetailStateContent buildContentState({bool lazyLoading = false, ChanSingleEvent? event}) {
    ThreadDetailModel? threadDetailModel;
    if (searchQuery.isNotNullNorEmpty) {
      List<PostItem> posts;
      List<PostItem> titleMatchThreads = _threadDetailModel!.visiblePosts
          .where((post) => (post.subtitle ?? "").containsIgnoreCase(searchQuery))
          .toList();
      List<PostItem> bodyMatchThreads = _threadDetailModel!.visiblePosts
          .where((post) => (post.content ?? "").containsIgnoreCase(searchQuery))
          .toList();
      posts = LinkedHashSet<PostItem>.from(titleMatchThreads + bodyMatchThreads).toList();
      threadDetailModel = _threadDetailModel!.copyWith(thread: _threadDetailModel!.thread, posts: posts);
    } else {
      threadDetailModel = _threadDetailModel;
    }

    return ThreadDetailStateContent(
      model: threadDetailModel!,
      isFavorite: threadDetailModel.isFavorite,
      catalogMode: _catalogMode ?? false,
      event: event,
      showLazyLoading: lazyLoading,
      showSearchBar: showSearchBar,
      customThreads: customThreads,
    );
  }
}
