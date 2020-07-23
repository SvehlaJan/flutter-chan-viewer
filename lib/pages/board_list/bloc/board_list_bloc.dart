import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/board_list_model.dart';
import 'package:flutter_chan_viewer/models/helper/chan_board_item_wrapper.dart';
import 'package:flutter_chan_viewer/models/ui/board_item.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';

import 'board_list_state.dart';

class BoardListBloc extends Bloc<ChanEvent, ChanState> {
  final ChanRepository _repository = getIt<ChanRepository>();

  BoardListBloc() : super(ChanStateLoading());

  String searchQuery = "";

  @override
  Stream<ChanState> mapEventToState(ChanEvent event) async* {
    try {
      if (event is ChanEventFetchData) {
        yield ChanStateLoading();
        List<ChanBoardItemWrapper> resultList;

        bool showSfwOnly = Preferences.getBool(Preferences.KEY_SETTINGS_SHOW_SFW_ONLY, def: true);
        List<String> favoriteBoardIds = Preferences.getStringList(Preferences.KEY_FAVORITE_BOARDS);

        BoardListModel boardListModel = await _repository.fetchCachedBoardList();
        if (boardListModel != null) {
          resultList = _processBoardList(favoriteBoardIds, showSfwOnly, boardListModel);
          yield BoardListStateContent(resultList, true);
        }

        boardListModel = await _repository.fetchRemoteBoardList();
        resultList = _processBoardList(favoriteBoardIds, showSfwOnly, boardListModel);
        yield BoardListStateContent(resultList, false);
      } else if (event is ChanEventSearch) {
        searchQuery = event.query;
        add(ChanEventFetchData());
      }
    } catch (e, stackTrace) {
      ChanLogger.e("Event error!", e, stackTrace);
      yield ChanStateError(e.toString());
    }
  }

  List<ChanBoardItemWrapper> _processBoardList(List<String> favoriteBoardIds, bool showSfwOnly, BoardListModel boardListModel) {
    List<BoardItem> filteredBoards = boardListModel.boards.where((board) => _matchesFilter(board, searchQuery, showSfwOnly)).toList();
    List<BoardItem> favoriteBoards = filteredBoards.where((board) => favoriteBoardIds.contains(board.boardId)).toList();
    List<BoardItem> otherBoards = filteredBoards.where((board) => !favoriteBoardIds.contains(board.boardId)).toList();
    List<ChanBoardItemWrapper> resultList = [];

    if (favoriteBoards.isNotEmpty) {
      resultList.add(ChanBoardItemWrapper(headerTitle: "Favorites"));
      resultList.addAll(favoriteBoards.map((board) => ChanBoardItemWrapper(chanBoard: board)));
      if (otherBoards.isNotEmpty) {
        resultList.add(ChanBoardItemWrapper(headerTitle: "Others"));
      }
    }
    resultList.addAll(otherBoards.map((board) => ChanBoardItemWrapper(chanBoard: board)));
    return resultList;
  }

  bool _matchesFilter(BoardItem board, String query, bool showSfwOnly) {
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
