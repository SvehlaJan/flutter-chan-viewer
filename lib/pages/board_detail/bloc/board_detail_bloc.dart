import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/board_detail_model.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';

import 'board_detail_event.dart';
import 'board_detail_state.dart';

class BoardDetailBloc extends Bloc<ChanEvent, ChanState> {
  final ChanRepository _repository = getIt<ChanRepository>();

  BoardDetailBloc(this.boardId) : super(ChanStateLoading());

  final String boardId;
  bool isFavorite = false;
  String searchQuery = "";

  @override
  Stream<ChanState> mapEventToState(ChanEvent event) async* {
    try {
      if (event is ChanEventFetchData) {
        yield ChanStateLoading();
        List<ChanThread> filteredThreads;
        List<String> favoriteBoards = Preferences.getStringList(Preferences.KEY_FAVORITE_BOARDS);
        isFavorite = favoriteBoards.contains(boardId);

        BoardDetailModel boardDetailModel = await _repository.fetchCachedBoardDetail(boardId);
        if (boardDetailModel != null) {
          filteredThreads = boardDetailModel.threads.where((thread) => _matchesQuery(thread, searchQuery)).toList();
          yield BoardDetailStateContent(filteredThreads, true, isFavorite);
        }

        boardDetailModel = await _repository.fetchRemoteBoardDetail(boardId);
        filteredThreads = boardDetailModel.threads.where((thread) => _matchesQuery(thread, searchQuery)).toList();
        yield BoardDetailStateContent(filteredThreads, false, isFavorite);
      } else if (event is ChanEventSearch) {
        searchQuery = event.query;
        add(ChanEventFetchData());
      } else if (event is BoardDetailEventToggleFavorite) {
        isFavorite = !isFavorite;
        List<String> favoriteBoards = Preferences.getStringList(Preferences.KEY_FAVORITE_BOARDS);
        favoriteBoards.removeWhere((value) => value == boardId);
        if (isFavorite) {
          favoriteBoards.add(boardId);
        }
        Preferences.setStringList(Preferences.KEY_FAVORITE_BOARDS, favoriteBoards);
        add(ChanEventFetchData());
      }
    } catch (e, stackTrace) {
      ChanLogger.e("Event error!", e, stackTrace);
      yield ChanStateError(e.toString());
    }
  }

  bool _matchesQuery(ChanThread thread, String query) {
    return thread.subtitle?.toLowerCase()?.contains(query.toLowerCase()) ?? thread.content?.toLowerCase()?.contains(query.toLowerCase()) ?? false;
  }
}
