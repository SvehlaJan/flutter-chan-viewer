import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/chan_post.dart';
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
  int _preSelectedPostId;

  ThreadDetailModel _threadDetailModel;

  ThreadDetailBloc(this._boardId, this._threadId, this._showAppBar, this._showDownloadsOnly, this._catalogMode, this._preSelectedPostId);

  @override
  get initialState => ThreadDetailStateLoading();

  int get selectedPostIndex => _threadDetailModel.selectedPostIndex;

  set selectedPostIndex(int postIndex) => _threadDetailModel.selectedPostIndex = postIndex;

  int get selectedMediaIndex => _threadDetailModel.selectedMediaIndex;

  set selectedMediaIndex(int mediaIndex) => _threadDetailModel.selectedMediaIndex = mediaIndex;

  set selectedPostId(int postId) => _threadDetailModel.selectedPostId = postId;

  int get selectedPostId => _threadDetailModel.selectedPostId;

  String get pageTitle => "/$_boardId/$_threadId";

  bool get catalogMode => _catalogMode ?? false;

  bool get isFavorite => _isFavorite ?? false;

  @override
  Stream<ThreadDetailState> mapEventToState(ThreadDetailEvent event) async* {
    try {
      if (event is ThreadDetailEventFetchPosts) {
        yield ThreadDetailStateLoading();

        if (_showDownloadsOnly ?? false) {
          DownloadFolderInfo folderInfo = _chanStorage.getThreadDownloadFolderInfo(CacheDirective(_boardId, _threadId));
          _threadDetailModel = ThreadDetailModel.fromFolderInfo(folderInfo);
        } else {
          _threadDetailModel = await _repository.fetchThreadDetail(event.forceFetch, _boardId, _threadId);
        }

        if (_preSelectedPostId >= 0) {
          selectedPostId = _preSelectedPostId;
          _preSelectedPostId = null;
        }

        _isFavorite = _repository.isThreadFavorite(_threadDetailModel.cacheDirective);
        if (_catalogMode == null) {
          _catalogMode = Preferences.getBool(Preferences.KEY_THREAD_CATALOG_MODE, def: false);
        }

        yield _getShowListState();
      } else if (event is ThreadDetailEventToggleFavorite) {
        yield ThreadDetailStateLoading();

        _isFavorite = !_isFavorite;
        if (_isFavorite) {
          await _repository.addThreadToFavorites(_threadDetailModel);
        } else {
          await _repository.removeThreadFromFavorites(_threadDetailModel);
        }

        yield _getShowListState();
      } else if (event is ThreadDetailEventToggleCatalogMode) {
        yield ThreadDetailStateLoading();

        _catalogMode = !_catalogMode;
        Preferences.setBool(Preferences.KEY_THREAD_CATALOG_MODE, _catalogMode);

        yield _getShowListState();
      } else if (event is ThreadDetailEventDownload) {
        yield ThreadDetailStateLoading();

        _repository.downloadAllMedia(_threadDetailModel);

        yield _getShowListState();
      } else if (event is ThreadDetailEventOnPostSelected) {
        if (event.mediaIndex != null) {
          selectedMediaIndex = event.mediaIndex;
        } else if (event.postId != null) {
          selectedPostId = event.postId;
        }

        yield _getShowListState();
      } else if (event is ThreadDetailEventOnLinkClicked) {
        ChanPost post = _threadDetailModel.findPostById(ChanUtil.getPostIdFromUrl(event.url));
        if (post != null) {
          selectedPostId = post.postId;
          if (!post.hasMedia()) {
            _catalogMode = false;
          }
        }

        yield _getShowListState();
      } else if (event is ThreadDetailEventOnReplyClicked) {
        ChanPost post = _threadDetailModel.findPostById(event.postId);
        if (post != null) {
          selectedPostId = post.postId;
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

  ThreadDetailStateContent _getShowListState({bool lazyLoading = false}) {
    return ThreadDetailStateContent(_threadDetailModel, selectedPostId, _showAppBar, _isFavorite, _catalogMode, lazyLoading);
  }
}
