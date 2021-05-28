import 'dart:async';

import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/board_list_model.dart';
import 'package:flutter_chan_viewer/models/helper/chan_board_item_wrapper.dart';
import 'package:flutter_chan_viewer/models/ui/board_item.dart';
import 'package:flutter_chan_viewer/pages/base/base_bloc.dart';
import 'package:flutter_chan_viewer/pages/board_list/bloc/board_list_state.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';
import 'package:flutter_chan_viewer/utils/extensions.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';

class BoardListBloc extends BaseBloc<ChanEvent, ChanState> {
  final ChanRepository _repository = getIt<ChanRepository>();
  late List<BoardItem> favoriteBoards;
  late List<BoardItem> otherBoards;

  BoardListBloc() : super(ChanStateLoading());

  @override
  Stream<ChanState> mapEventToState(ChanEvent event) async* {
    try {
      if (event is ChanEventFetchData) {
        yield ChanStateLoading();

        bool showNsfw = Preferences.getBool(Preferences.KEY_SETTINGS_SHOW_NSFW, def: false);
        List<String?> favoriteBoardIds = Preferences.getStringList(Preferences.KEY_FAVORITE_BOARDS);

        BoardListModel? boardListModel = await _repository.fetchCachedBoardList(showNsfw);
        if (boardListModel != null) {
          favoriteBoards = boardListModel.boards.where((board) => favoriteBoardIds.contains(board.boardId)).toList();
          otherBoards = boardListModel.boards.where((board) => !favoriteBoardIds.contains(board.boardId)).toList();
          yield _buildContentState(true);
        }

        boardListModel = await _repository.fetchRemoteBoardList(showNsfw);
        favoriteBoards = boardListModel!.boards.where((board) => favoriteBoardIds.contains(board.boardId)).toList();
        otherBoards = boardListModel.boards.where((board) => !favoriteBoardIds.contains(board.boardId)).toList();
        yield _buildContentState(false);
      } else if (event is ChanEventSearch || event is ChanEventShowSearch || event is ChanEventCloseSearch) {
        mapEventDefaults(event);
        yield _buildContentState(false);
      }
    } catch (e, stackTrace) {
      ChanLogger.e("Event error!", e, stackTrace);
      yield ChanStateError(e.toString());
    }
  }

  BoardListStateContent _buildContentState(bool showLazyLoading) {
    List<ChanBoardItemWrapper> boards = [];
    List<ChanBoardItemWrapper> filteredFavoriteBoards =
        favoriteBoards.where((board) => _matchesQuery(board, searchQuery)).map((board) => ChanBoardItemWrapper(chanBoard: board)).toList();
    List<ChanBoardItemWrapper> filteredOtherBoards =
        otherBoards.where((board) => _matchesQuery(board, searchQuery)).map((board) => ChanBoardItemWrapper(chanBoard: board)).toList();
    if (filteredFavoriteBoards.isNotEmpty) {
      boards.add(ChanBoardItemWrapper(headerTitle: "Favorites"));
      boards.addAll(filteredFavoriteBoards);
      if (otherBoards.isNotEmpty) {
        boards.add(ChanBoardItemWrapper(headerTitle: "Others"));
      }
    }
    boards.addAll(filteredOtherBoards);

    return BoardListStateContent(boards: boards, showLazyLoading: showLazyLoading, showSearchBar: showSearchBar);
  }

  bool _matchesQuery(BoardItem board, String query) {
    return board.boardId.containsIgnoreCase(query) || board.title.containsIgnoreCase(query);
  }
}
