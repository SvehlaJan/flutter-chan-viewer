import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/pages/base/base_bloc.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/repositories/chan_result.dart';
import 'package:flutter_chan_viewer/repositories/posts_repository.dart';
import 'package:flutter_chan_viewer/repositories/threads_repository.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/exceptions.dart';
import 'package:flutter_chan_viewer/utils/extensions.dart';
import 'package:flutter_chan_viewer/utils/log_utils.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import 'thread_detail_event.dart';
import 'thread_detail_state.dart';

class ThreadDetailBloc extends BaseBloc<ChanEvent, ChanState> {
  final logger = LogUtils.getLogger();
  final ThreadsRepository _threadsRepository = getIt<ThreadsRepository>();
  final PostsRepository _postsRepository = getIt<PostsRepository>();
  final Preferences _preferences = getIt<Preferences>();

  final String _boardId;
  final int _threadId;
  final bool? _showDownloadsOnly;
  bool? _catalogMode;
  ThreadDetailModel? _threadDetailModel;
  List<ThreadItem>? customThreads = null;

  CacheDirective get cacheDirective => CacheDirective(_boardId, _threadId);
  ReceivePort _port = ReceivePort();
  late final StreamSubscription _subscription;

  ThreadDetailBloc(this._boardId, this._threadId, this._showDownloadsOnly) : super(ChanStateLoading()) {

    _catalogMode = _preferences.getBool(Preferences.KEY_THREAD_CATALOG_MODE, def: false);

    IsolateNameServer.registerPortWithName(_port.sendPort, Constants.downloaderPortName);
    _port.listen((dynamic data) {
      String postId = data[0];
      int progress = data[1];
      logger.d("Download progress: $postId - $progress");
    });

    _subscription = _threadsRepository.fetchAndObserveThreadDetail(_boardId, _threadId).listen((data) {
      add(ChanEventDataFetched(data));
    }, onError: (e) {
      add(ChanEventDataError(e));
    });

    on<ChanEventInitBloc>((event, emit) async {
      emit(ChanStateLoading());
    });

    on<ChanEventFetchData>((event, emit) async {
      emit(buildContentState(lazyLoading: true));

      try {
        await _threadsRepository.fetchRemoteThreadDetail(_boardId, _threadId, false);
      } catch (e) {
        if (e is HttpException || e is SocketException) {
          emit(buildContentState(event: ChanSingleEvent.SHOW_OFFLINE));
        } else {
          rethrow;
        }
      }

      // TODO - add show downloads only
      // if (_showDownloadsOnly ?? false) {
      //   DownloadFolderInfo folderInfo = _chanStorage.getThreadDownloadFolderInfo(cacheDirective);
      //   _threadDetailModel = ThreadDetailModel.fromFolderInfo(folderInfo);
      //   emit(buildContentState(lazyLoading: false));
      //   return;
      // }

      try {
        // ThreadDetailModel remoteThread = await _repository.fetchRemoteThreadDetail(_boardId, _threadId, false);

        // TODO - update last seen post index
        // if (_threadDetailModel!.thread.lastSeenPostIndex < remoteThread.thread.replies) {
        //   ThreadItem? updatedThread = await _repository
        //       .updateThread(remoteThread.thread.copyWith(lastSeenPostIndex: remoteThread.thread.replies));
        //   _threadDetailModel = remoteThread.copyWith(thread: updatedThread);
        // } else {
        //   _threadDetailModel = remoteThread;
        // }

        // emit(buildContentState(lazyLoading: false));
      } catch (e) {
        if (e is HttpException || e is SocketException) {
          emit(buildContentState(event: ChanSingleEvent.SHOW_OFFLINE));
        } else {
          rethrow;
        }
      }
    });

    on<ChanEventDataFetched>((event, emit) {
      if (event.result is Loading) {
        if (event.result.data != null) {
          _threadDetailModel = event.result.data;
          emit(buildContentState(lazyLoading: true));
        } else {
          emit(ChanStateLoading());
        }
      } else if (event.result is Success) {
        _threadDetailModel = event.result.data;
        emit(buildContentState(lazyLoading: false));
      } else if (event.result is Error) {
        if (event.result.data is HttpException || event.result.data is SocketException) {
          emit(buildContentState(event: ChanSingleEvent.SHOW_OFFLINE));
        } else {
          emit(ChanStateError(event.result.data.toString()));
        }
      }
    });

    on<ChanEventDataError>((event, emit) {
      if (event.error is HttpException || event.error is SocketException) {
        emit(buildContentState(event: ChanSingleEvent.SHOW_OFFLINE));
      } else {
        emit(ChanStateError(event.error.toString()));
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
          await _threadsRepository.removeThreadFromFavorites(_threadDetailModel!);
          emit(buildContentState(event: ChanSingleEvent.CLOSE_PAGE));
        } else {
          emit(buildContentState(event: ThreadDetailSingleEvent.SHOW_UNSTAR_WARNING));
        }
      } else {
        emit(ChanStateLoading());

        await _threadsRepository.addThreadToFavorites(_threadDetailModel!);
      }
    });

    on<ThreadDetailEventToggleCatalogMode>((event, emit) {
      emit(ChanStateLoading());
      _catalogMode = !_catalogMode!;
      _preferences.setBool(Preferences.KEY_THREAD_CATALOG_MODE, _catalogMode!);
      emit(buildContentState(event: ThreadDetailSingleEvent.SCROLL_TO_SELECTED));
    });

    on<ThreadDetailEventOnPostSelected>((event, emit) async {
      await _threadsRepository.updateThread(_threadDetailModel!.thread.copyWith(selectedPostId: event.postId));
    });

    on<ThreadDetailEventOnLinkClicked>((event, emit) async {
      int postId = ChanUtil.getPostIdFromUrl(event.url);
      if (postId > 0) {
        add(ThreadDetailEventOnPostSelected(postId));
      }
    });

    on<ThreadDetailEventDeleteCollection>((event, emit) async {
      await _threadsRepository.deleteCustomThread(_threadDetailModel!);
      emit(buildContentState(event: ChanSingleEvent.CLOSE_PAGE));
    });
  }

  @override
  Future<void> close() {
    IsolateNameServer.removePortNameMapping(Constants.downloaderPortName);
    _subscription.cancel();
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
      customThreads: customThreads ?? [],
    );
  }
}
