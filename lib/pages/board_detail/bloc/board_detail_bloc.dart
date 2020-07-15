import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/board_detail_model.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';

import 'board_detail_event.dart';
import 'board_detail_state.dart';

class BoardDetailBloc extends Bloc<BoardDetailEvent, BoardDetailState> {
  final ChanRepository _repository = getIt<ChanRepository>();

  BoardDetailBloc(this.boardId) : super(BoardDetailStateLoading());

  final String boardId;
  bool isFavorite = false;
  String searchQuery = "";

  @override
  Stream<BoardDetailState> mapEventToState(BoardDetailEvent event) async* {
    try {
      if (event is BoardDetailEventFetchThreads) {
        yield BoardDetailStateLoading();
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
      } else if (event is BoardDetailEventSearchBoards) {
        searchQuery = event.query;
        add(BoardDetailEventFetchThreads());
      } else if (event is BoardDetailEventToggleFavorite) {
        isFavorite = !isFavorite;
        List<String> favoriteBoards = Preferences.getStringList(Preferences.KEY_FAVORITE_BOARDS);
        favoriteBoards.removeWhere((value) => value == boardId);
        if (isFavorite) {
          favoriteBoards.add(boardId);
        }
        Preferences.setStringList(Preferences.KEY_FAVORITE_BOARDS, favoriteBoards);
        add(BoardDetailEventFetchThreads());
      }
    } catch (e, stackTrace) {
      ChanLogger.e("Event error!", e, stackTrace);
      yield BoardDetailStateError(e.toString());
    }
  }

  bool _matchesQuery(ChanThread thread, String query) {
    return thread.subtitle?.toLowerCase()?.contains(query.toLowerCase()) ?? thread.content?.toLowerCase()?.contains(query.toLowerCase()) ?? false;
  }
}
