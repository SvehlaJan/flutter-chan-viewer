import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/helper/online_state.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/models/ui/post_item_vo.dart';
import 'package:flutter_chan_viewer/repositories/chan_result.dart';
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

class ThreadDetailBloc extends Bloc<ChanEvent, ThreadDetailState> {
  final logger = LogUtils.getLogger();
  final ThreadsRepository _threadsRepository = getIt<ThreadsRepository>();
  final Preferences _preferences = getIt<Preferences>();

  final String _boardId;
  final int _threadId;
  final bool? _showDownloadsOnly;
  late bool _catalogMode;
  late ThreadDetailModel _threadDetailModel;
  bool _showSearchBar = false;
  String searchQuery = "";

  ReceivePort _port = ReceivePort();
  late final StreamSubscription _subscription;

  ThreadDetailBloc(this._boardId, this._threadId, this._showDownloadsOnly) : super(ThreadDetailStateLoading()) {
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
      emit(ThreadDetailStateLoading());
    });

    on<ChanEventFetchData>((event, emit) async {
      emit(buildContentState(lazyLoading: true));

      try {
        await _threadsRepository.fetchRemoteThreadDetail(_boardId, _threadId, false, markAsSeen: true);
      } catch (e) {
        if (e is HttpException || e is SocketException) {
          emit(buildContentState(event: ThreadDetailSingleEventShowOffline()));
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
    });

    on<ChanEventDataFetched>((event, emit) {
      if (event.result is Loading) {
        if (event.result.data != null) {
          _threadDetailModel = event.result.data;
          emit(buildContentState(lazyLoading: true));
        } else {
          emit(ThreadDetailStateLoading());
        }
      } else if (event.result is Success) {
        _threadDetailModel = event.result.data;
        emit(buildContentState(lazyLoading: false));
      } else if (event.result is Failure) {
        Exception exception = (event.result as Failure).exception;
        if (exception is HttpException || exception is SocketException) {
          emit(buildContentState(event: ThreadDetailSingleEventShowOffline()));
        } else {
          emit(ThreadDetailStateError(exception.toString()));
        }
      }
    });

    on<ChanEventDataError>((event, emit) {
      if (event.error is HttpException || event.error is SocketException) {
        emit(buildContentState(event: ThreadDetailSingleEventShowOffline()));
      } else {
        emit(ThreadDetailStateError(event.error.toString()));
      }
    });

    on<ThreadDetailEventToggleFavorite>((event, emit) async {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      if (statuses.values.any((status) => status.isGranted == false)) {
        emit(ThreadDetailStateError("This feature requires permission to access storage"));
        return;
      }

      if (_threadDetailModel.isFavorite) {
        if (event.confirmed) {
          await _threadsRepository.removeThreadFromFavorites(_threadDetailModel);
          emit(buildContentState(event: ThreadDetailSingleEventClosePage()));
        } else {
          emit(buildContentState(event: ThreadDetailSingleEventShowUnstarWarning()));
        }
      } else {
        emit(ThreadDetailStateLoading());

        await _threadsRepository.addThreadToFavorites(_threadDetailModel);
      }
    });

    on<ThreadDetailEventToggleCatalogMode>((event, emit) {
      emit(ThreadDetailStateLoading());
      _catalogMode = !_catalogMode;
      _preferences.setBool(Preferences.KEY_THREAD_CATALOG_MODE, _catalogMode);
      emit(buildContentState(event: ThreadDetailSingleEventScrollToSelected()));
    });

    on<ThreadDetailEventOnPostClicked>((event, emit) async {
      await _threadsRepository.updateThread(_threadDetailModel.thread.copyWith(selectedPostId: event.postId));
      emit(buildContentState(event: ThreadDetailSingleEventOpenGallery(event.postId, _threadId, _boardId)));
    });

    on<ThreadDetailEventOnLinkClicked>((event, emit) async {
      int postId = ChanUtil.getPostIdFromUrl(event.url);
      if (postId > 0) {
        add(ThreadDetailEventOnPostClicked(postId));
      }
    });

    on<ThreadDetailEventDeleteThread>((event, emit) async {
      await _threadsRepository.deleteCustomThread(_threadDetailModel);
      emit(buildContentState(event: ThreadDetailSingleEventClosePage()));
    });

    on<ChanEventSearch>((event, emit) {
      searchQuery = event.query;
      emit(buildContentState());
    });

    on<ChanEventShowSearch>((event, emit) {
      _showSearchBar = true;
      emit(buildContentState());
    });

    on<ChanEventCloseSearch>((event, emit) {
      searchQuery = "";
      _showSearchBar = false;
      emit(buildContentState());
    });
  }

  @override
  Future<void> close() {
    IsolateNameServer.removePortNameMapping(Constants.downloaderPortName);
    _subscription.cancel();
    return super.close();
  }

  ThreadDetailState buildContentState({bool lazyLoading = false, ThreadDetailSingleEvent? event}) {
    late ThreadDetailModel threadDetailModel;
    if (searchQuery.isNotEmpty) {
      List<PostItem> posts;
      List<PostItem> titleMatchThreads = _threadDetailModel.visiblePosts
          .where((post) => (post.subtitle ?? "").containsIgnoreCase(searchQuery))
          .toList();
      List<PostItem> bodyMatchThreads = _threadDetailModel.visiblePosts
          .where((post) => (post.content ?? "").containsIgnoreCase(searchQuery))
          .toList();
      posts = LinkedHashSet<PostItem>.from(titleMatchThreads + bodyMatchThreads).toList();
      threadDetailModel = _threadDetailModel.copyWith(thread: _threadDetailModel.thread, posts: posts);
    } else {
      threadDetailModel = _threadDetailModel;
    }

    List<PostItem> posts = _catalogMode ? threadDetailModel.visibleMediaPosts : threadDetailModel.visiblePosts;
    return ThreadDetailStateContent(
      posts: posts.map((e) => e.toPostItemVO()).toList(),
      selectedPostIndex: _catalogMode ? threadDetailModel.selectedMediaIndex : threadDetailModel.selectedPostIndex,
      isFavorite: threadDetailModel.isFavorite,
      isCustomThread: threadDetailModel.thread.onlineStatus == OnlineState.CUSTOM,
      catalogMode: _catalogMode,
      event: event,
      showLazyLoading: lazyLoading,
      showSearchBar: _showSearchBar,
    );
  }
}
