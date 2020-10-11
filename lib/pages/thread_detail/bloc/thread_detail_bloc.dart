import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/data/remote/app_exception.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/utils/extensions.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import 'thread_detail_event.dart';
import 'thread_detail_state.dart';

class ThreadDetailBloc extends Bloc<ChanEvent, ChanState> {
  final ChanRepository _repository = getIt<ChanRepository>();
  final ChanStorage _chanStorage = getIt<ChanStorage>();
  final String _boardId;
  final int _threadId;
  final bool _showDownloadsOnly;
  bool _catalogMode;

  ThreadDetailModel _threadDetailModel;

  ThreadDetailBloc(
    this._boardId,
    this._threadId,
    this._showDownloadsOnly
  ) : super(ChanStateLoading());

  String get pageTitle => "/$_boardId/$_threadId";

  bool get catalogMode => _catalogMode ?? false;

  bool get isFavorite => _threadDetailModel?.thread?.isFavorite() ?? false;

  CacheDirective get cacheDirective => CacheDirective(_boardId, _threadId);

  List<ThreadItem> customThreads = [];

  @override
  Stream<ChanState> mapEventToState(ChanEvent event) async* {
    try {
      if (event is ChanEventInitBloc) {
        yield ChanStateLoading();

        if (_catalogMode == null) {
          _catalogMode = Preferences.getBool(Preferences.KEY_THREAD_CATALOG_MODE, def: false);
        }
        customThreads = await _repository.getCustomThreads();

        add(ChanEventFetchData());
      }
      if (event is ChanEventFetchData) {
        yield ChanStateLoading();

        if (_showDownloadsOnly ?? false) {
          DownloadFolderInfo folderInfo = _chanStorage.getThreadDownloadFolderInfo(cacheDirective);
          _threadDetailModel = ThreadDetailModel.fromFolderInfo(folderInfo);
          yield _getShowListState(lazyLoading: false);
          return;
        }

        _threadDetailModel = await _repository.fetchCachedThreadDetail(_boardId, _threadId);
        if (_threadDetailModel != null) {
          yield _getShowListState(lazyLoading: true, event: ThreadDetailSingleEvent.SCROLL_TO_SELECTED);
        }
        try {
          _threadDetailModel = await _repository.fetchRemoteThreadDetail(_boardId, _threadId, false);
        } on HttpException catch (e, stackTrace) {
          yield _getShowListState(event: ThreadDetailSingleEvent.SHOW_OFFLINE);
        }
        yield _getShowListState(lazyLoading: false);
      } else if (event is ThreadDetailEventToggleFavorite) {
        if (!await Permission.storage.request().isGranted) {
          yield ChanStateError("This feature requires permission to access external storage");
          return;
        }

        if (isFavorite) {
          yield _getShowListState(event: ThreadDetailSingleEvent.SHOW_UNSTAR_WARNING);
          return;
        } else {
          yield ChanStateLoading();

          await _repository.addThreadToFavorites(_threadDetailModel);

          add(ChanEventFetchData());
        }
      } else if (event is ThreadDetailEventDialogAnswered) {
        if (!isFavorite) {
          // invalid state
          yield _getShowListState();
          return;
        }

        if (event.confirmed) {
          await _repository.removeThreadFromFavorites(_threadDetailModel);
          yield _getShowListState(event: ThreadDetailSingleEvent.CLOSE_PAGE);
        } else {
          yield _getShowListState();
        }
      } else if (event is ThreadDetailEventToggleCatalogMode) {
        yield ChanStateLoading();

        _catalogMode = !_catalogMode;
        Preferences.setBool(Preferences.KEY_THREAD_CATALOG_MODE, _catalogMode);

        yield _getShowListState(event: ThreadDetailSingleEvent.SCROLL_TO_SELECTED);
      } else if (event is ThreadDetailEventOnPostSelected) {
        int newPostId = -1;
        if (event.mediaIndex != null) {
          newPostId = _threadDetailModel.mediaPosts[event.mediaIndex].postId;
        } else if (event.postId != null) {
          newPostId = event.postId;
        }

        _threadDetailModel.thread = _threadDetailModel.thread.copyWith(selectedPostId: newPostId);
        _repository.updateThread(_threadDetailModel.thread);

        yield _getShowListState(event: ThreadDetailSingleEvent.SCROLL_TO_SELECTED);
      } else if (event is ThreadDetailEventOnLinkClicked) {
        PostItem post = _threadDetailModel.findPostById(ChanUtil.getPostIdFromUrl(event.url));
        if (post != null) {
          _threadDetailModel.thread = _threadDetailModel.thread.copyWith(selectedPostId: post.postId);
          _repository.updateThread(_threadDetailModel.thread);
        }

        yield _getShowListState(event: ThreadDetailSingleEvent.SCROLL_TO_SELECTED);
      } else if (event is ThreadDetailEventOnReplyClicked) {
        PostItem post = _threadDetailModel.findPostById(event.postId);
        if (post != null) {
          _threadDetailModel.thread = _threadDetailModel.thread.copyWith(selectedPostId: post.postId);
          _repository.updateThread(_threadDetailModel.thread);
        }

        yield _getShowListState(event: ThreadDetailSingleEvent.SCROLL_TO_SELECTED);
      } else if (event is ThreadDetailEventHidePost) {
      } else if (event is ThreadDetailEventCreateNewCollection) {
        await _repository.createCustomThread(event.name);
        customThreads = await _repository.getCustomThreads();
        yield _getShowListState(event: ThreadDetailSingleEvent.SHOW_COLLECTIONS_DIALOG);
      } else if (event is ThreadDetailEventAddPostToCollection) {
        ThreadItem thread = customThreads.where((element) => element.subtitle == event.name).firstOrNull;
        PostItem post = _threadDetailModel.selectedPost;
        _repository.addPostToCustomThread(post, thread);
        yield _getShowListState(event: ThreadDetailSingleEvent.SHOW_POST_ADDED_TO_COLLECTION_SUCCESS);
      }
    } catch (e, stackTrace) {
      ChanLogger.e("Event error!", e, stackTrace);
      yield ChanStateError(e.toString());
    }
  }

  ThreadDetailStateContent _getShowListState({bool lazyLoading = false, ThreadDetailSingleEvent event}) {
    return ThreadDetailStateContent(_threadDetailModel, _threadDetailModel?.selectedPostId, isFavorite, _catalogMode, lazyLoading, event);
  }
}
