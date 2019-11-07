import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/models/boards_model.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'board_list_event.dart';
import 'board_list_state.dart';

class BoardListBloc extends Bloc<BoardListEvent, BoardListState> {
  final _repository = ChanRepository.get();

  BoardListBloc();

  void initBloc() {}

  @override
  get initialState => BoardListStateLoading();

  @override
  Stream<BoardListState> mapEventToState(BoardListEvent event) async* {
    print("Event received! ${event.toString()}");
    print("Current state! ${currentState.toString()}");
    try {
      if (event is BoardListEventFetchBoards) {
        yield BoardListStateLoading();

        final boards = await _repository.fetchBoards();
        List<String> favoriteBoardIds = (await SharedPreferences.getInstance()).getStringList(Preferences.KEY_FAVORITE_BOARDS) ?? [];
        List<ChanBoard> favoriteBoards = [];
        List<ChanBoard> otherBoards = [];
        for (ChanBoard board in boards.boards) {
          if (favoriteBoardIds.contains(board.boardId)) {
            favoriteBoards.add(board);
          } else {
            otherBoards.add(board);
          }
        }
        yield BoardListStateContent(favoriteBoards, otherBoards);
      }
    } catch (o) {
      print("Event error! ${o.toString()}");
      yield BoardListStateError(o.toString());
    }
  }
}
