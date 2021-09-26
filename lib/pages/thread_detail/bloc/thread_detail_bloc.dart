import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/data/remote/app_exception.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/pages/base/base_bloc.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/extensions.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';

import 'thread_detail_event.dart';
import 'thread_detail_state.dart';

class ThreadDetailBloc extends BaseBloc<ChanEvent, ChanState> {
  final ChanRepository _repository = getIt<ChanRepository>();
  final ChanStorage _chanStorage = getIt<ChanStorage>();

  final String _boardId;
  final int _threadId;
  final bool? _showDownloadsOnly;
  bool _showHidden = false;
  bool? _catalogMode;
  ThreadDetailModel? _threadDetailModel;
  List<ThreadItem> customThreads = [];

  CacheDirective get cacheDirective => CacheDirective(_boardId, _threadId);
  ReceivePort _port = ReceivePort();

  ThreadDetailBloc(this._boardId, this._threadId, this._showDownloadsOnly) : super(ChanStateLoading());

  @override
  Stream<ChanState> mapEventToState(ChanEvent event) async* {
    try {
      if (event is ChanEventInitBloc) {
        yield ChanStateLoading();

        if (_catalogMode == null) {
          _catalogMode = Preferences.getBool(Preferences.KEY_THREAD_CATALOG_MODE, def: false);
        }
        customThreads = await _repository.getCustomThreads();

        IsolateNameServer.registerPortWithName(_port.sendPort, Constants.downloaderPortName);
        _port.listen((dynamic data) async* {
          String taskId = data[0];
          DownloadTaskStatus status = data[1];
          int progress = data[2];

          if (status == DownloadTaskStatus.complete && progress == 100) {
            await ChanDownloader.onDownloadFinished(taskId);
            yield _buildContentState(lazyLoading: false);
          }
        });

        add(ChanEventFetchData());
      }
      if (event is ChanEventOnDispose) {
        IsolateNameServer.removePortNameMapping(Constants.downloaderPortName);
      }
      if (event is ChanEventFetchData) {
        yield ChanStateLoading();

        if (_showDownloadsOnly ?? false) {
          DownloadFolderInfo folderInfo = _chanStorage.getThreadDownloadFolderInfo(cacheDirective);
          _threadDetailModel = ThreadDetailModel.fromFolderInfo(folderInfo);
          yield _buildContentState(lazyLoading: false);
          return;
        }

        _threadDetailModel = await _repository.fetchCachedThreadDetail(_boardId, _threadId);
        if (_threadDetailModel != null && _threadDetailModel!.visiblePosts.isNotNullNorEmpty) {
          yield _buildContentState(lazyLoading: true, event: ThreadDetailSingleEvent.SCROLL_TO_SELECTED);
        }

        try {
          ThreadDetailModel remoteThread = await _repository.fetchRemoteThreadDetail(_boardId, _threadId, false);

          if (remoteThread.isFavorite) {
            _repository.downloadAllMedia(remoteThread);
          }

          if (_threadDetailModel!.thread.lastSeenPostIndex < remoteThread.thread.replies) {
            ThreadItem? updatedThread = await _repository.updateThread(remoteThread.thread.copyWith(lastSeenPostIndex: remoteThread.thread.replies));
            _threadDetailModel = remoteThread.copyWith(thread: updatedThread);
          } else {
            _threadDetailModel = remoteThread;
          }
          yield _buildContentState(lazyLoading: false);
        } catch (e) {
          if (e is HttpException || e is SocketException) {
            yield _buildContentState(event: ChanSingleEvent.SHOW_OFFLINE);
          } else {
            rethrow;
          }
        }
      } else if (event is ThreadDetailEventToggleFavorite) {
        if (!await Permission.storage.request().isGranted) {
          yield ChanStateError("This feature requires permission to access external storage");
          return;
        }

        if (_threadDetailModel?.isFavorite ?? false) {
          if (event.confirmed) {
            await _repository.removeThreadFromFavorites(_threadDetailModel!);
            yield _buildContentState(event: ChanSingleEvent.CLOSE_PAGE);
          } else {
            yield _buildContentState(event: ThreadDetailSingleEvent.SHOW_UNSTAR_WARNING);
          }
        } else {
          yield ChanStateLoading();

          ThreadItem? updatedThread = await _repository.addThreadToFavorites(_threadDetailModel!);
          _threadDetailModel = _threadDetailModel!.copyWith(thread: updatedThread);
          yield _buildContentState(lazyLoading: false);
        }
      } else if (event is ThreadDetailEventToggleCatalogMode) {
        yield ChanStateLoading();

        _catalogMode = !_catalogMode!;
        Preferences.setBool(Preferences.KEY_THREAD_CATALOG_MODE, _catalogMode!);

        yield _buildContentState(event: ThreadDetailSingleEvent.SCROLL_TO_SELECTED);
      } else if (event is ThreadDetailEventOnPostSelected) {
        int? newPostId = -1;
        if (event.mediaIndex != null) {
          newPostId = _threadDetailModel!.visibleMediaPosts[event.mediaIndex!].postId;
        } else if (event.postId != null) {
          newPostId = event.postId;
        }

        _threadDetailModel = _threadDetailModel!.copyWith(thread: _threadDetailModel!.thread.copyWith(selectedPostId: newPostId));
        await _repository.updateThread(_threadDetailModel!.thread);

        yield _buildContentState(event: ThreadDetailSingleEvent.SCROLL_TO_SELECTED);
      } else if (event is ThreadDetailEventOnLinkClicked) {
        PostItem? post = _threadDetailModel!.findPostById(ChanUtil.getPostIdFromUrl(event.url));
        if (post != null) {
          _threadDetailModel = _threadDetailModel!.copyWith(thread: _threadDetailModel!.thread.copyWith(selectedPostId: post.postId));
          await _repository.updateThread(_threadDetailModel!.thread);
        }

        yield _buildContentState(event: ThreadDetailSingleEvent.SCROLL_TO_SELECTED);
      } else if (event is ThreadDetailEventOnReplyClicked) {
        PostItem? post = _threadDetailModel!.findPostById(event.postId);
        if (post != null) {
          _threadDetailModel = _threadDetailModel!.copyWith(thread: _threadDetailModel!.thread.copyWith(selectedPostId: post.postId));
          await _repository.updateThread(_threadDetailModel!.thread);
        }

        yield _buildContentState(event: ThreadDetailSingleEvent.SCROLL_TO_SELECTED);
      } else if (event is ThreadDetailEventHidePost) {
        PostItem post = _threadDetailModel!.findPostById(event.postId)!.copyWith(isHidden: true);
        await _repository.updatePost(post);

        int? newSelectedPostId = -1;
        for (int i = 0; i < _threadDetailModel!.allPosts.length; i++) {
          int dilatation = (i ~/ 2) + 1;
          int orientation = i % 2;
          int diff = orientation == 0 ? -dilatation : dilatation;
          int newSelectedPostIndex = (_threadDetailModel!.selectedPostIndex + diff) % _threadDetailModel!.allPosts.length;
          PostItem newSelectedPost = _threadDetailModel!.allPosts[newSelectedPostIndex];
          if (!newSelectedPost.isHidden) {
            newSelectedPostId = newSelectedPost.postId;
            break;
          }
        }
        _threadDetailModel = _threadDetailModel!.copyWith(thread: _threadDetailModel!.thread.copyWith(selectedPostId: newSelectedPostId));
        await _repository.updateThread(_threadDetailModel!.thread);

        _threadDetailModel = await _repository.fetchCachedThreadDetail(_boardId, _threadId);
        yield _buildContentState(lazyLoading: false, event: ThreadDetailSingleEvent.SCROLL_TO_SELECTED);
      } else if (event is ThreadDetailEventCreateNewCollection) {
        await _repository.createCustomThread(event.name);
        customThreads = await _repository.getCustomThreads();
        yield _buildContentState(event: ThreadDetailSingleEvent.SHOW_COLLECTIONS_DIALOG);
      } else if (event is ThreadDetailEventAddPostToCollection) {
        ThreadItem thread = customThreads.where((element) => element.subtitle == event.name).firstOrNull!;
        PostItem post = _threadDetailModel!.findPostById(event.postId)!;
        await _repository.addPostToCustomThread(post, thread);
        yield _buildContentState(event: ThreadDetailSingleEvent.SHOW_POST_ADDED_TO_COLLECTION_SUCCESS);
      } else if (event is ThreadDetailEventDeleteCollection) {
        await _repository.deleteCustomThread(_threadDetailModel!);
        yield _buildContentState(event: ChanSingleEvent.CLOSE_PAGE);
      } else if (event is ChanEventSearch || event is ChanEventShowSearch || event is ChanEventCloseSearch) {
        mapEventDefaults(event);
        yield _buildContentState(lazyLoading: false);
      }
    } catch (e, stackTrace) {
      ChanLogger.e("Event error!", e, stackTrace);
      yield ChanStateError(e.toString());
    }
  }

  ThreadDetailStateContent _buildContentState({bool lazyLoading = false, ChanSingleEvent? event}) {
    ThreadDetailModel? threadDetailModel;
    if (searchQuery.isNotNullNorEmpty) {
      List<PostItem> posts;
      List<PostItem> titleMatchThreads = _threadDetailModel!.visiblePosts.where((post) => (post.subtitle ?? "").containsIgnoreCase(searchQuery)).toList();
      List<PostItem> bodyMatchThreads = _threadDetailModel!.visiblePosts.where((post) => (post.content ?? "").containsIgnoreCase(searchQuery)).toList();
      posts = LinkedHashSet<PostItem>.from(titleMatchThreads + bodyMatchThreads).toList();
      threadDetailModel = _threadDetailModel!.copyWith(thread: _threadDetailModel!.thread, posts: posts);
    } else {
      threadDetailModel = _threadDetailModel;
    }

    return ThreadDetailStateContent(
      model: threadDetailModel,
      selectedPostId: threadDetailModel?.selectedPostId,
      isFavorite: threadDetailModel?.isFavorite ?? false,
      catalogMode: _catalogMode ?? false,
      event: event,
      showLazyLoading: lazyLoading,
      showSearchBar: showSearchBar,
      customThreads: customThreads,
    );
  }
}
