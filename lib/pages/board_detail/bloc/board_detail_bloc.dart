import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/models/board_detail_model.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'board_detail_event.dart';
import 'board_detail_state.dart';

class BoardDetailBloc extends Bloc<BoardDetailEvent, BoardDetailState> {
  final _repository = ChanRepository.getSync();

  BoardDetailBloc(this.boardId);

  void initBloc() {}

  @override
  get initialState => BoardDetailStateLoading();

  final String boardId;
  bool isFavorite = false;
  String searchQuery = "";

  @override
  Stream<BoardDetailState> mapEventToState(BoardDetailEvent event) async* {
    try {
      if (event is BoardDetailEventFetchThreads) {
        yield BoardDetailStateLoading();

        BoardDetailModel boardDetailModel = await _repository.fetchBoardDetail(event.forceFetch, boardId);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> favoriteBoards = prefs.getStringList(Preferences.KEY_FAVORITE_BOARDS) ?? [];
        isFavorite = favoriteBoards.contains(boardId);
        List<ChanThread> filteredThreads = boardDetailModel.threads.where((thread) => _matchesQuery(thread, searchQuery)).toList();

        yield BoardDetailStateContent(filteredThreads, isFavorite);
      } else if (event is BoardDetailEventSearchBoards) {
        searchQuery = event.query;
        add(BoardDetailEventFetchThreads(false));
      } else if (event is BoardDetailEventToggleFavorite) {
        isFavorite = !isFavorite;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> favoriteBoards = prefs.getStringList(Preferences.KEY_FAVORITE_BOARDS) ?? [];
        favoriteBoards.removeWhere((value) => value == boardId);
        if (isFavorite) {
          favoriteBoards.add(boardId);
        }
        prefs.setStringList(Preferences.KEY_FAVORITE_BOARDS, favoriteBoards);
        add(BoardDetailEventFetchThreads(false));
      }
    } catch (o) {
      print("Event error! ${o.toString()}");
      yield BoardDetailStateError(o.toString());
    }
  }

  bool _matchesQuery(ChanThread thread, String query) => thread.content?.toLowerCase()?.contains(query.toLowerCase()) ?? false;
}
