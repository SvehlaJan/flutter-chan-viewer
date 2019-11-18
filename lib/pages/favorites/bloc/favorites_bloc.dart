import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/models/board_list_model.dart';
import 'package:flutter_chan_viewer/models/board_detail_model.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final _repository = ChanRepository.get();

  @override
  get initialState => FavoritesStateLoading();

  @override
  Stream<FavoritesState> mapEventToState(FavoritesEvent event) async* {
    print("Event received! ${event.toString()}");
    print("Current state! ${state.toString()}");
    try {
      if (event is FavoritesEventFetchData) {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        final boards = await _repository.fetchBoardList();
        List<String> favoriteBoardIds = prefs.getStringList(Preferences.KEY_FAVORITE_BOARDS) ?? [];
        List<ChanBoard> filteredBoards = boards.boards.where((board) => favoriteBoardIds.contains(board.boardId)).toList();

        List<String> favoriteThreadIds = prefs.getStringList(Preferences.KEY_FAVORITE_THREADS) ?? [];
        List<ChanThread> threads = [];


        yield FavoritesStateContent(filteredBoards, threads);
      }
    } catch (o) {
      print("Event error! ${o.toString()}");
      yield FavoritesStateError(o.toString());
    }
  }
}
