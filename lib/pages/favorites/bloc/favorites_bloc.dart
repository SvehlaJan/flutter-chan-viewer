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

import 'favorites_state.dart';

class FavoritesBloc extends Bloc<ChanEvent, ChanState> {
  final ChanRepository _repository = getIt<ChanRepository>();
  static const int DETAIL_REFRESH_TIMEOUT = 60 * 1000; // 60 seconds
  List<FavoritesThreadWrapper> _favoriteThreads = List<FavoritesThreadWrapper>();
  int _currentRefreshIndex = 0;
  int _lastDetailRefreshTimestamp = 0;

  FavoritesBloc() : super(ChanStateLoading());

  @override
  Stream<ChanState> mapEventToState(ChanEvent event) async* {
    try {
      if (event is ChanEventFetchData) {
        yield ChanStateLoading();

        List<ThreadDetailModel> threads = await _repository.getFavoriteThreads();
        bool showSfwOnly = Preferences.getBool(Preferences.KEY_SETTINGS_SHOW_SFW_ONLY, def: true);
        if (showSfwOnly) {
          List<String> sfwBoardIds = (await _repository.fetchCachedBoardList(false)).boards.map((board) => board.boardId).toList();
          threads.removeWhere((model) => !sfwBoardIds.contains(model.thread.boardId));
        }
        _favoriteThreads = threads.map((e) => FavoritesThreadWrapper(e)).toList();
        _currentRefreshIndex = 0;

        int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
        if (event.forceRefresh || currentTimestamp - _lastDetailRefreshTimestamp > DETAIL_REFRESH_TIMEOUT) {
          _lastDetailRefreshTimestamp = currentTimestamp;
          add(FavoritesEventFetchDetail(_currentRefreshIndex));
        } else {
          yield FavoritesStateContent(List.from(_favoriteThreads), false);
        }
      } else if (event is FavoritesEventFetchDetail) {
        ThreadDetailModel cachedThread = _favoriteThreads[_currentRefreshIndex].threadDetailModel;
        ThreadDetailModel refreshedThread;

        _favoriteThreads[_currentRefreshIndex] = FavoritesThreadWrapper(cachedThread, isLoading: true);
        yield FavoritesStateContent(List.from(_favoriteThreads), true);

        int newReplies = _favoriteThreads[_currentRefreshIndex].newReplies;
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

        _favoriteThreads[_currentRefreshIndex] = FavoritesThreadWrapper(refreshedThread ?? cachedThread, newReplies: newReplies);
        _currentRefreshIndex++;
        if (_currentRefreshIndex < _favoriteThreads.length) {
          yield FavoritesStateContent(List.from(_favoriteThreads), true);
          add(FavoritesEventFetchDetail(_currentRefreshIndex));
        } else {
          yield FavoritesStateContent(List.from(_favoriteThreads), false);
        }
      }
    } catch (e, stackTrace) {
      ChanLogger.e("Event error!", e, stackTrace);
      yield ChanStateError(e.toString());
    }
  }
}
