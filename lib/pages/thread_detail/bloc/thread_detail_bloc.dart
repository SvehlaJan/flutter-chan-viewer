import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:equatable/equatable.dart';
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
import 'package:flutter_chan_viewer/utils/media_helper.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import 'thread_detail_event.dart';
import 'thread_detail_state.dart';

class ThreadDetailBloc extends Bloc<ChanEvent, ThreadDetailState> with ChanLogger {
  final ThreadsRepository _threadsRepository = getIt<ThreadsRepository>();
  final MediaHelper _mediaHelper = getIt<MediaHelper>();
  final Preferences _preferences = getIt<Preferences>();

  final String _boardId;
  final int _threadId;
  final bool? _showDownloadsOnly;
  late bool _catalogMode;
  late ThreadDetailModel _threadDetailModel;
  bool _showSearchBar = false;
  String searchQuery = "";
  bool _downloadRequested = false;

  ReceivePort _port = ReceivePort();
  late final StreamSubscription _threadModelSubscription;

  ThreadDetailBloc(this._boardId, this._threadId, this._showDownloadsOnly) : super(ThreadDetailStateLoading()) {
    _catalogMode = _preferences.getBool(Preferences.KEY_THREAD_CATALOG_MODE, def: false);

    IsolateNameServer.registerPortWithName(_port.sendPort, Constants.downloaderPortName);
    _port.listen((dynamic data) {
      String postId = data[0];
      int progress = data[1];
      logDebug("Download progress: $postId - $progress");
    });

    _threadModelSubscription = _threadsRepository.fetchAndObserveThreadDetail(_boardId, _threadId).listen((data) {
      add(ChanEventDataFetched(data));
    }, onError: (e) {
      add(ChanEventDataError(e));
    });

    on<ChanEventInitBloc>((event, emit) async {
      emit(ThreadDetailStateLoading());
    });

    on<ChanEventFetchData>((event, emit) async {
      emit(await buildContentState(lazyLoading: true));

      try {
        await _threadsRepository.fetchRemoteThreadDetail(_boardId, _threadId, false, markAsSeen: true);
      } catch (e) {
        if (e is HttpException || e is SocketException) {
          emit(await buildContentState(event: ThreadDetailSingleEventShowOffline()));
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

    on<ChanEventDataFetched>((event, emit) async {
      logDebug("Thread data fetched: ${event.result}");
      if (event.result is Loading) {
        ThreadDetailModel? model = event.result.data;
        if (model != null && model.hasPosts) {
          _threadDetailModel = model;
          emit(await buildContentState(lazyLoading: true));
        } else {
          emit(ThreadDetailStateLoading());
        }
      } else if (event.result is Success) {
        _threadDetailModel = event.result.data;

        if (!_downloadRequested && _threadDetailModel.isFavorite) {
          _downloadRequested = true;
          await _threadsRepository.downloadAllMedia(_threadDetailModel);
        }

        emit(await buildContentState());
      } else if (event.result is Failure) {
        Exception exception = (event.result as Failure).exception;
        if (exception is HttpException || exception is SocketException) {
          emit(await buildContentState(event: ThreadDetailSingleEventShowOffline()));
        } else {
          emit(ThreadDetailStateError(exception.toString()));
        }
      }
    });

    on<ChanEventDataError>((event, emit) async {
      if (event.error is HttpException || event.error is SocketException) {
        emit(await buildContentState(event: ThreadDetailSingleEventShowOffline()));
      } else {
        emit(ThreadDetailStateError(event.error.toString()));
      }
    });

    on<ThreadDetailEventToggleFavorite>((event, emit) async {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.manageExternalStorage,
      ].request();
      if (statuses.values.any((status) => status.isGranted == false)) {
        emit(ThreadDetailStateError("This feature requires permission to access storage"));
        return;
      }

      if (_threadDetailModel.isFavorite) {
        if (event.confirmed) {
          await _threadsRepository.removeThreadFromFavorites(_threadDetailModel);
          // TODO - revert
          // emit(await buildContentState(event: ThreadDetailSingleEventClosePage()));
        } else {
          emit(await buildContentState(event: ThreadDetailSingleEventShowUnstarWarning()));
        }
      } else {
        emit(ThreadDetailStateLoading());

        await _threadsRepository.addThreadToFavorites(_threadDetailModel);
      }
    });

    on<ThreadDetailEventToggleCatalogMode>((event, emit) async {
      emit(ThreadDetailStateLoading());
      _catalogMode = !_catalogMode;
      _preferences.setBool(Preferences.KEY_THREAD_CATALOG_MODE, _catalogMode);
      emit(await buildContentState(event: ThreadDetailSingleEventScrollToSelected()));
    });

    on<ThreadDetailEventOnPostClicked>((event, emit) async {
      await _threadsRepository.updateThread(_threadDetailModel.thread.copyWith(selectedPostId: event.postId));
      emit(await buildContentState(event: ThreadDetailSingleEventOpenGallery(event.postId, _threadId, _boardId)));
    });

    on<ThreadDetailEventOnLinkClicked>((event, emit) async {
      int postId = ChanUtil.getPostIdFromUrl(event.url);
      if (postId > 0) {
        add(ThreadDetailEventOnPostClicked(postId));
      }
    });

    on<ThreadDetailEventDeleteThread>((event, emit) async {
      await _threadsRepository.deleteCustomThread(_threadDetailModel);
      emit(await buildContentState(event: ThreadDetailSingleEventClosePage()));
    });

    on<ChanEventSearch>((event, emit) async {
      searchQuery = event.query;
      emit(await buildContentState());
    });

    on<ChanEventShowSearch>((event, emit) async {
      _showSearchBar = true;
      emit(await buildContentState());
    });

    on<ChanEventCloseSearch>((event, emit) async {
      searchQuery = "";
      _showSearchBar = false;
      emit(await buildContentState());
    });
  }

  @override
  Future<void> close() {
    IsolateNameServer.removePortNameMapping(Constants.downloaderPortName);
    _threadModelSubscription.cancel();
    return super.close();
  }

  Future<ThreadDetailState> buildContentState({bool lazyLoading = false, ThreadDetailSingleEvent? event}) async {
    List<PostItem> posts = _catalogMode ? _threadDetailModel.visibleMediaPosts : _threadDetailModel.visiblePosts;
    if (searchQuery.isNotEmpty) {
      List<PostItem> titleMatchThreads = _threadDetailModel.visiblePosts
          .where((post) => (post.subtitle ?? "").containsIgnoreCase(searchQuery))
          .toList();
      List<PostItem> bodyMatchThreads = _threadDetailModel.visiblePosts
          .where((post) => (post.content ?? "").containsIgnoreCase(searchQuery))
          .toList();
      posts = LinkedHashSet<PostItem>.from(titleMatchThreads + bodyMatchThreads).toList();
    }
    return ThreadDetailStateContent(
      posts: await posts.toPostItemVOList(_mediaHelper),
      selectedPostIndex: _catalogMode ? _threadDetailModel.selectedMediaIndex : _threadDetailModel.selectedPostIndex,
      isFavorite: _threadDetailModel.isFavorite,
      isCustomThread: _threadDetailModel.thread.onlineStatus == OnlineState.CUSTOM,
      catalogMode: _catalogMode,
      event: event,
      showLazyLoading: lazyLoading,
      showSearchBar: _showSearchBar,
    );
  }
}

extension on ThreadDetailModel {
  Future<ThreadDetailState> toThreadDetailState({
    bool lazyLoading = false,
    ThreadDetailSingleEvent? event = null,
    required MediaHelper mediaHelper,
    required bool catalogMode,
    required bool showSearchBar,
    required String searchQuery,
  }) async {
    List<PostItem> posts = catalogMode ? visibleMediaPosts : visiblePosts;
    if (searchQuery.isNotEmpty) {
      List<PostItem> titleMatchThreads =
          visiblePosts.where((post) => (post.subtitle ?? "").containsIgnoreCase(searchQuery)).toList();
      List<PostItem> bodyMatchThreads =
          visiblePosts.where((post) => (post.content ?? "").containsIgnoreCase(searchQuery)).toList();
      posts = LinkedHashSet<PostItem>.from(titleMatchThreads + bodyMatchThreads).toList();
    }

    return ThreadDetailStateContent(
      posts: await posts.toPostItemVOList(mediaHelper),
      selectedPostIndex: catalogMode ? selectedMediaIndex : selectedPostIndex,
      isFavorite: isFavorite,
      isCustomThread: thread.onlineStatus == OnlineState.CUSTOM,
      catalogMode: catalogMode,
      showSearchBar: showSearchBar,
      showLazyLoading: lazyLoading,
      event: event,
    );
  }
}
