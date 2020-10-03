import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/pages/favorites/bloc/favorites_event.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import 'favorites_state.dart';

class FavoritesBloc extends Bloc<ChanEvent, ChanState> {
  final ChanRepository _repository = getIt<ChanRepository>();
  static const int DETAIL_REFRESH_TIMEOUT = 60 * 1000; // 60 seconds
  List<FavoritesThreadWrapper> _favoriteThreads = List<FavoritesThreadWrapper>();
  List<FavoritesThreadWrapper> _customThreads = List<FavoritesThreadWrapper>();
  int _currentFavoritesRefreshIndex = 0;
  int _lastDetailRefreshTimestamp = 0;

  FavoritesBloc() : super(ChanStateLoading());

  @override
  Stream<ChanState> mapEventToState(ChanEvent event) async* {
    try {
      if (event is ChanEventFetchData) {
        yield ChanStateLoading();

        if (!await Permission.storage.request().isGranted) {
          yield ChanStateError("This feature requires permission to access external storage");
          return;
        }

        List<ThreadDetailModel> threads = await _repository.getFavoriteThreads();
        bool showSfwOnly = Preferences.getBool(Preferences.KEY_SETTINGS_SHOW_SFW_ONLY, def: true);
        if (showSfwOnly) {
          List<String> sfwBoardIds = (await _repository.fetchCachedBoardList(false)).boards.map((board) => board.boardId).toList();
          threads.removeWhere((model) => !sfwBoardIds.contains(model.thread.boardId));
        }
        _favoriteThreads = threads.map((e) => FavoritesThreadWrapper(e)).toList();
        _currentFavoritesRefreshIndex = 0;
        _customThreads = (await _repository.getCustomThreads()).map((thread) => FavoritesThreadWrapper(ThreadDetailModel.fromThreadAndPosts(thread, []))).toList();

        int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
        bool shouldRefreshDetails = event.forceRefresh || currentTimestamp - _lastDetailRefreshTimestamp > DETAIL_REFRESH_TIMEOUT;
        if (_favoriteThreads.isNotEmpty && shouldRefreshDetails) {
          _lastDetailRefreshTimestamp = currentTimestamp;
          add(FavoritesEventFetchDetail(_currentFavoritesRefreshIndex));
        } else {
          yield _getContentState();
        }
      } else if (event is FavoritesEventFetchDetail) {
        ThreadDetailModel cachedThread = _favoriteThreads[_currentFavoritesRefreshIndex].threadDetailModel;
        ThreadDetailModel refreshedThread;

        _favoriteThreads[_currentFavoritesRefreshIndex] = FavoritesThreadWrapper(cachedThread, isLoading: true);
        yield _getContentState(lazyLoading: true);

        int newReplies = _favoriteThreads[_currentFavoritesRefreshIndex].newReplies;
        try {
          refreshedThread = await _repository.fetchRemoteThreadDetail(cachedThread.thread.boardId, cachedThread.thread.threadId, false);
          int newMedia = refreshedThread.thread.images - cachedThread.thread.images;
          newReplies += refreshedThread.thread.replies - cachedThread.thread.replies;
          if (newMedia > 0) {
            _repository.downloadAllMedia(refreshedThread);
          }
        } catch (e) {
          ChanLogger.e("Failed to load favorite thread", e);
        }

        _favoriteThreads[_currentFavoritesRefreshIndex] = FavoritesThreadWrapper(refreshedThread ?? cachedThread, newReplies: newReplies);
        _currentFavoritesRefreshIndex++;
        if (_currentFavoritesRefreshIndex < _favoriteThreads.length) {
          yield _getContentState(lazyLoading: true);
          add(FavoritesEventFetchDetail(_currentFavoritesRefreshIndex));
        } else {
          yield _getContentState();
        }
      }
    } catch (e, stackTrace) {
      ChanLogger.e("Event error!", e, stackTrace);
      yield ChanStateError(e.toString());
    }
  }

  FavoritesStateContent _getContentState({bool lazyLoading = false}) {
    List<FavoritesItemWrapper> items = [];
    if (_favoriteThreads.isNotEmpty) {
      items.add(FavoritesItemWrapper(true, null, "Threads"));
      items.addAll(_favoriteThreads.map((thread) => FavoritesItemWrapper(false, thread, null)));
    }
    if (_customThreads.isNotEmpty) {
      items.add(FavoritesItemWrapper(true, null, "Collections"));
      items.addAll(_customThreads.map((thread) => FavoritesItemWrapper(false, thread, null)));
    }
    return FavoritesStateContent(items, lazyLoading);
  }
}
