import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/models/api/boards_model.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'board_list_event.dart';
import 'board_list_state.dart';

class BoardListBloc extends Bloc<BoardListEvent, BoardListState> {
  final _repository = ChanRepository.get();
  final _showOnlyFavorites;

  BoardListBloc(this._showOnlyFavorites);

  void initBloc() {}

  @override
  get initialState => BoardListStateLoading();

  @override
  Stream<BoardListState> mapEventToState(BoardListEvent event) async* {
    print("Event received! ${event.toString()}");
    print("Current state! ${currentState.toString()}");
    try {
      if (event is BoardListEventAppStarted) {
        initBloc();
        yield BoardListStateLoading();
      }
      if (event is BoardListEventFetchBoards) {
        yield BoardListStateLoading();

        final boards = await _repository.fetchAllBoards();
        if (_showOnlyFavorites) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          List<String> favoriteBoards = prefs.getStringList(Preferences.KEY_FAVORITE_BOARDS) ?? [];
          List<ChanBoard> filteredBoards = boards.boards.where((board) => favoriteBoards.contains(board.boardId)).toList();
          yield BoardListStateContent(filteredBoards, _showOnlyFavorites);
        } else {
          yield BoardListStateContent(boards.boards, _showOnlyFavorites);
        }
      }
    } catch (o) {
      print("Event error! ${o.toString()}");
      yield BoardListStateError(o.toString());
    }
  }
}
