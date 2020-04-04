import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/board_list_model.dart';
import 'package:flutter_chan_viewer/models/helper/chan_board_item_wrapper.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';

import 'board_list_event.dart';
import 'board_list_state.dart';

class BoardListBloc extends Bloc<BoardListEvent, BoardListState> {
  final ChanRepository _repository = getIt<ChanRepository>();

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
        bool showSfwOnly = Preferences.getBool(Preferences.KEY_SETTINGS_SHOW_SFW_ONLY, def: true);
        List<ChanBoard> filteredBoards = boardListModel.boards.where((board) => _matchesFilter(board, searchQuery, showSfwOnly)).toList();
        List<String> favoriteBoardIds = Preferences.getStringList(Preferences.KEY_FAVORITE_BOARDS);
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
    } catch (e, stackTrace) {
      ChanLogger.e("Event error!", e, stackTrace);
      yield BoardListStateError(e.toString());
    }
  }

  bool _matchesFilter(ChanBoard board, String query, bool showSfwOnly) {
    if (showSfwOnly && !board.workSafe) {
      return false;
    }
    if (query.isNotEmpty) {
      if (!board.boardId.toLowerCase().startsWith(query.toLowerCase()) && !board.title.toLowerCase().startsWith(query.toLowerCase())) {
        return false;
      }
    }
    return true;
  }
}
