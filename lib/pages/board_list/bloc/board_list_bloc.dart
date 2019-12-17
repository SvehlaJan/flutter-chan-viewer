import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/models/board_list_model.dart';
import 'package:flutter_chan_viewer/models/helper/chan_board_item_wrapper.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'board_list_event.dart';
import 'board_list_state.dart';

class BoardListBloc extends Bloc<BoardListEvent, BoardListState> {
  final _repository = ChanRepository.getSync();

  void initBloc() {}

  @override
  get initialState => BoardListStateLoading();

  String searchQuery = "";

  @override
  Stream<BoardListState> mapEventToState(BoardListEvent event) async* {
    try {
      if (event is BoardListEventFetchBoards) {
        yield BoardListStateLoading();

        BoardListModel boardListModel = await _repository.fetchBoardList(event.forceFetch);
        List<ChanBoard> filteredBoards = boardListModel.boards.where((board) => _matchesQuery(board, searchQuery)).toList();
        List<String> favoriteBoardIds = (await SharedPreferences.getInstance()).getStringList(Preferences.KEY_FAVORITE_BOARDS) ?? [];
        List<ChanBoard> favoriteBoards = filteredBoards.where((board) => favoriteBoardIds.contains(board.boardId)).toList();
        List<ChanBoard> otherBoards = filteredBoards.where((board) => !favoriteBoardIds.contains(board.boardId)).toList();
        List<ChanBoardItemWrapper> resultList = [];

        if (favoriteBoards.isNotEmpty) {
          resultList.add(ChanBoardItemWrapper(headerTitle: "Favorites"));
          resultList.addAll(favoriteBoards.map((board) => ChanBoardItemWrapper(chanBoard: board)));
          if (otherBoards.isNotEmpty) {
            resultList.add(ChanBoardItemWrapper(headerTitle: "Others"));
          }
        }
        resultList.addAll(otherBoards.map((board) => ChanBoardItemWrapper(chanBoard: board)));

        yield BoardListStateContent(resultList);
      } else if (event is BoardListEventSearchBoards) {
        searchQuery = event.query;
        add(BoardListEventFetchBoards(false));
      }
    } catch (o) {
      print("Event error! ${o.toString()}");
      yield BoardListStateError(o.toString());
    }
  }

  bool _matchesQuery(ChanBoard board, String query) => board.boardId.toLowerCase().startsWith(query.toLowerCase()) || board.title.toLowerCase().startsWith(query.toLowerCase());
}
