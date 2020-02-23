import 'dart:async';

import 'package:bloc/bloc.dart';
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
  final _repository = ChanRepository.getSync();
  final _chanStorage = ChanStorage.getSync();
  final String boardId;
  final int threadId;
  final bool showDownloadsOnly;

  ThreadDetailModel _threadDetailModel;
  bool catalogMode = true;
  bool isFavorite = false;

  ThreadDetailBloc(this.boardId, this.threadId, this.showDownloadsOnly);

  @override
  get initialState => ThreadDetailStateLoading();

  get selectedPostIndex => _threadDetailModel.selectedPostIndex;

  get selectedMediaIndex => _threadDetailModel.selectedMediaIndex;

  set selectedMediaIndex(int mediaIndex) => _threadDetailModel.selectedMediaIndex = mediaIndex;

  set selectedPostId(int postId) => _threadDetailModel.selectedPostId = postId;

  get selectedPostId => _threadDetailModel.selectedPostId;

  @override
  Stream<ThreadDetailState> mapEventToState(ThreadDetailEvent event) async* {
    try {
      if (event is ThreadDetailEventShowContent) {
        yield _getShowListState();
      } else if (event is ThreadDetailEventFetchPosts) {
        yield ThreadDetailStateLoading();

        if (showDownloadsOnly) {
          DownloadFolderInfo folderInfo = _chanStorage.getThreadDownloadFolderInfo(CacheDirective(boardId, threadId));
          _threadDetailModel = ThreadDetailModel.fromFolderInfo(folderInfo);
        } else {
          _threadDetailModel = await _repository.fetchCachedThreadDetail(boardId, threadId);
          if (_threadDetailModel != null) {
            yield _getShowListState(lazyLoading: true);
          }
          _threadDetailModel = await _repository.fetchThreadDetail(event.forceFetch, boardId, threadId);
        }

        yield _getShowListState();
      } else if (event is ThreadDetailEventToggleFavorite) {
        yield ThreadDetailStateLoading();

        isFavorite = !isFavorite;
        if (isFavorite) {
          await _repository.addThreadToFavorites(_threadDetailModel);
        } else {
          await _repository.removeThreadFromFavorites(_threadDetailModel);
        }

        yield _getShowListState();
      } else if (event is ThreadDetailEventToggleCatalogMode) {
        yield ThreadDetailStateLoading();

        catalogMode = !catalogMode;
        Preferences.setBool(Preferences.KEY_THREAD_CATALOG_MODE, catalogMode);

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
        int postIndex = _threadDetailModel.getPostIndex(ChanUtil.getPostIdFromUrl(event.url));
        if (postIndex > 0) {
          selectedMediaIndex = postIndex;
        }

        yield _getShowListState();
      } else if (event is ThreadDetailEventOnReplyClicked) {
        selectedPostId = event.postId;
        yield ThreadDetailStateCloseGallery();
      }
    } catch (e) {
      ChanLogger.e("Event error!", e);
      yield ThreadDetailStateError(e.toString());
    }
  }

  ThreadDetailStateShowList _getShowListState({bool lazyLoading = false}) {
    isFavorite = _repository.isThreadFavorite(_threadDetailModel.cacheDirective);
    catalogMode = Preferences.getBool(Preferences.KEY_THREAD_CATALOG_MODE) ?? false;
    return ThreadDetailStateShowList(_threadDetailModel, selectedPostId, isFavorite, catalogMode, lazyLoading);
  }

  ThreadDetailStateShowGallery _getShowGalleryState() {
    return ThreadDetailStateShowGallery(_threadDetailModel, selectedPostId);
  }
}
