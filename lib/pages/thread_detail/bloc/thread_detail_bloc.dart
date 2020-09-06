import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';

import 'thread_detail_event.dart';
import 'thread_detail_state.dart';

class ThreadDetailBloc extends Bloc<ChanEvent, ChanState> {
  final ChanRepository _repository = getIt<ChanRepository>();
  final ChanStorage _chanStorage = getIt<ChanStorage>();
  final String _boardId;
  final int _threadId;
  final bool _showDownloadsOnly;
  final bool _showAppBar;
  bool _catalogMode;
  bool _isFavorite;
  StreamSubscription subscription;

  ThreadDetailModel _threadDetailModel;

  ThreadDetailBloc(
    this._boardId,
    this._threadId,
    this._showAppBar,
    this._showDownloadsOnly,
    this._catalogMode,
  ) : super(ChanStateLoading());

  String get pageTitle => "/$_boardId/$_threadId";

  bool get catalogMode => _catalogMode ?? false;

  bool get isFavorite => _isFavorite ?? false;

  CacheDirective get cacheDirective => CacheDirective(_boardId, _threadId);

  @override
  Stream<ChanState> mapEventToState(ChanEvent event) async* {
    try {
      if (event is ChanEventInitBloc) {
        yield ChanStateLoading();

        if (_catalogMode == null) {
          _catalogMode = Preferences.getBool(Preferences.KEY_THREAD_CATALOG_MODE, def: false);
        }
        _isFavorite = await _repository.isThreadFavorite(_boardId, _threadId);

        add(ChanEventFetchData());
      }
      if (event is ChanEventFetchData) {
        yield ChanStateLoading();

        if (_showDownloadsOnly ?? false) {
          DownloadFolderInfo folderInfo = _chanStorage.getThreadDownloadFolderInfo(cacheDirective);
          _threadDetailModel = ThreadDetailModel.fromFolderInfo(folderInfo);
          yield _getShowListState();
        } else {
          subscription?.cancel();
          subscription = _repository.getThreadDetailStream(_boardId, _threadId).listen((model) {
            if (model?.posts?.isNotEmpty ?? false) {
              add(ThreadDetailEventOnDataReceived(model));
            }
          });

          await _repository.fetchRemoteThreadDetail(_boardId, _threadId, false);
        }
      } else if (event is ThreadDetailEventOnDataReceived) {
        if (_isFavorite && _threadDetailModel != null) {
          int newMedia = (event.model.thread.images ?? 0) - (_threadDetailModel.thread.images ?? 0);
          if (newMedia > 0) {
            _repository.downloadAllMedia(_threadDetailModel);
          }
        }
        _threadDetailModel = event.model;
        bool firstData = _threadDetailModel == null;
        yield _getShowListState(lazyLoading: firstData, event: firstData ? ThreadDetailSingleEvent.SCROLL_TO_SELECTED : null);
      } else if (event is ThreadDetailEventToggleFavorite) {
        if (_isFavorite) {
          yield _getShowListState(event: ThreadDetailSingleEvent.SHOW_UNSTAR_WARNING);
          return;
        } else {
          yield ChanStateLoading();

          _isFavorite = true;
          await _repository.addThreadToFavorites(_threadDetailModel);
          _repository.downloadAllMedia(_threadDetailModel);

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
        yield ChanStateLoading();

        _catalogMode = !_catalogMode;
        Preferences.setBool(Preferences.KEY_THREAD_CATALOG_MODE, _catalogMode);

        yield _getShowListState(event: ThreadDetailSingleEvent.SCROLL_TO_SELECTED);
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
      yield ChanStateError(e.toString());
    }
  }

  ThreadDetailStateContent _getShowListState({bool lazyLoading = false, ThreadDetailSingleEvent event}) {
    return ThreadDetailStateContent(_threadDetailModel, _threadDetailModel?.selectedPostId, _showAppBar, _isFavorite, _catalogMode, lazyLoading, event);
  }

  @override
  Future<void> close() {
    subscription?.cancel();
    return super.close();
  }
}
