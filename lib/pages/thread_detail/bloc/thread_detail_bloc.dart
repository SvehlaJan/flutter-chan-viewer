import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/post_item.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';

import 'thread_detail_event.dart';
import 'thread_detail_state.dart';

class ThreadDetailBloc extends Bloc<ThreadDetailEvent, ThreadDetailState> {
  final ChanRepository _repository = getIt<ChanRepository>();
  final ChanStorage _chanStorage = getIt<ChanStorage>();
  final String _boardId;
  final int _threadId;
  final bool _showDownloadsOnly;
  final bool _showAppBar;
  bool _catalogMode;
  bool _isFavorite;

  ThreadDetailModel _threadDetailModel;

  ThreadDetailBloc(this._boardId, this._threadId, this._showAppBar, this._showDownloadsOnly, this._catalogMode);

  @override
  get initialState => ThreadDetailStateLoading();

  String get pageTitle => "/$_boardId/$_threadId";

  bool get catalogMode => _catalogMode ?? false;

  bool get isFavorite => _isFavorite ?? false;

  CacheDirective get cacheDirective => CacheDirective(_boardId, _threadId);

  @override
  Stream<ThreadDetailState> mapEventToState(ThreadDetailEvent event) async* {
    try {
      if (event is ThreadDetailEventFetchPosts) {
        yield ThreadDetailStateLoading();

        if (_catalogMode == null) {
          _catalogMode = Preferences.getBool(Preferences.KEY_THREAD_CATALOG_MODE, def: false);
        }
        _isFavorite = _repository.isThreadFavorite(cacheDirective);

        if (_showDownloadsOnly ?? false) {
          DownloadFolderInfo folderInfo = _chanStorage.getThreadDownloadFolderInfo(cacheDirective);
          _threadDetailModel = ThreadDetailModel.fromFolderInfo(folderInfo);
          yield _getShowListState();
        } else {
          ThreadDetailModel cachedThreadDetailModel = await _repository.fetchCachedThreadDetail(_boardId, _threadId);
          if (cachedThreadDetailModel != null) {
            _threadDetailModel = cachedThreadDetailModel;
            yield _getShowListState(lazyLoading: true, event: ThreadDetailSingleEvent.SCROLL_TO_SELECTED);
          }

          try {
            _threadDetailModel = await _repository.fetchRemoteThreadDetail(cacheDirective);
            if (cachedThreadDetailModel == null) {
              yield _getShowListState();
            } else {
              yield _getShowListState(event: ThreadDetailSingleEvent.SCROLL_TO_SELECTED);
            }
          } catch (e, stacktrace) {
            ChanLogger.e("Fetch error", e, stacktrace);
            yield _getShowListState(event: ThreadDetailSingleEvent.SHOW_OFFLINE);
          }
        }
      } else if (event is ThreadDetailEventToggleFavorite) {
        if (_isFavorite) {
          yield _getShowListState(event: ThreadDetailSingleEvent.SHOW_UNSTAR_WARNING);
          return;
        } else {
          yield ThreadDetailStateLoading();

          _isFavorite = true;
          await _repository.addThreadToFavorites(_threadDetailModel);

          yield _getShowListState();
        }
      } else if (event is ThreadDetailEventDialogAnswered) {
        if (!_isFavorite) {
          // invalid state
          yield _getShowListState();
          return;
        }

        if (event.confirmed) {
          _isFavorite = false;
          await _repository.removeThreadFromFavorites(_threadDetailModel);
          yield _getShowListState(event: ThreadDetailSingleEvent.CLOSE_PAGE);
        } else {
          yield _getShowListState();
        }
      } else if (event is ThreadDetailEventToggleCatalogMode) {
        yield ThreadDetailStateLoading();

        _catalogMode = !_catalogMode;
        Preferences.setBool(Preferences.KEY_THREAD_CATALOG_MODE, _catalogMode);

        yield _getShowListState(event: ThreadDetailSingleEvent.SCROLL_TO_SELECTED);
      } else if (event is ThreadDetailEventDownload) {
        yield ThreadDetailStateLoading();

        _repository.downloadAllMedia(_threadDetailModel);

        yield _getShowListState();
      } else if (event is ThreadDetailEventOnPostSelected) {
        if (event.mediaIndex != null) {
          _threadDetailModel.selectedMediaIndex = event.mediaIndex;
        } else if (event.postId != null) {
          _threadDetailModel.selectedPostId = event.postId;
        }

        yield _getShowListState(event: ThreadDetailSingleEvent.SCROLL_TO_SELECTED);
      } else if (event is ThreadDetailEventOnLinkClicked) {
        PostItem post = _threadDetailModel.findPostById(ChanUtil.getPostIdFromUrl(event.url));
        if (post != null) {
          _threadDetailModel.selectedPostId = post.postId;
          if (!post.hasMedia()) {
            _catalogMode = false;
          }
        }

        yield _getShowListState();
      } else if (event is ThreadDetailEventOnReplyClicked) {
        PostItem post = _threadDetailModel.findPostById(event.postId);
        if (post != null) {
          _threadDetailModel.selectedPostId = post.postId;
          if (!post.hasMedia()) {
            _catalogMode = false;
          }
        }

        yield _getShowListState();
      }
    } catch (e, stackTrace) {
      ChanLogger.e("Event error!", e, stackTrace);
      yield ThreadDetailStateError(e.toString());
    }
  }

  ThreadDetailStateContent _getShowListState({bool lazyLoading = false, ThreadDetailSingleEvent event}) {
    return ThreadDetailStateContent(_threadDetailModel, _threadDetailModel.selectedPostId, _showAppBar, _isFavorite, _catalogMode, lazyLoading, event);
  }
}
