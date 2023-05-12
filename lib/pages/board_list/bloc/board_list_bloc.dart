import 'dart:async';
import 'dart:io';

import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/board_list_model.dart';
import 'package:flutter_chan_viewer/models/helper/chan_board_item_wrapper.dart';
import 'package:flutter_chan_viewer/models/ui/board_item.dart';
import 'package:flutter_chan_viewer/pages/base/base_bloc.dart';
import 'package:flutter_chan_viewer/pages/board_list/bloc/board_list_state.dart';
import 'package:flutter_chan_viewer/repositories/boards_repository.dart';
import 'package:flutter_chan_viewer/repositories/chan_result.dart';
import 'package:flutter_chan_viewer/utils/exceptions.dart';
import 'package:flutter_chan_viewer/utils/extensions.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';

class BoardListBloc extends BaseBloc<ChanEvent, ChanState> {
  final BoardsRepository _repository = getIt<BoardsRepository>();
  final Preferences _preferences = getIt<Preferences>();
  late List<BoardItem> favoriteBoards;
  late List<BoardItem> otherBoards;

  late final StreamSubscription _subscription;

  BoardListBloc() : super(ChanStateLoading()) {

    bool includeNsfw = _preferences.getBool(Preferences.KEY_SETTINGS_SHOW_NSFW, def: false);
    List<String?> favoriteBoardIds = _preferences.getStringList(Preferences.KEY_FAVORITE_BOARDS);

    _subscription = _repository.fetchAndObserveBoardList(includeNsfw).listen((data) {
      add(ChanEventDataFetched(data));
    }, onError: (e) {
      add(ChanEventDataError(e));
    });

    on<ChanEventDataFetched<BoardListModel>>((event, emit) async {
      if (event.result is Loading) {
        BoardListModel? data = (event.result as Loading).data;
        if (data != null) {
          favoriteBoards = data.boards.where((board) => favoriteBoardIds.contains(board.boardId)).toList();
          otherBoards = data.boards.where((board) => !favoriteBoardIds.contains(board.boardId)).toList();
          emit(buildContentState(lazyLoading: true));
        } else {
          emit(ChanStateLoading());
        }
      } else if (event.result is Success) {
        BoardListModel data = (event.result as Success).data;
        favoriteBoards = data.boards.where((board) => favoriteBoardIds.contains(board.boardId)).toList();
        otherBoards = data.boards.where((board) => !favoriteBoardIds.contains(board.boardId)).toList();
        emit(buildContentState());
      }
    });

    on<ChanEventDataError>((event, emit) async {
      if (event.error is HttpException || event.error is SocketException) {
        emit(buildContentState(event: ChanSingleEvent.SHOW_OFFLINE));
      }
    });

    on<ChanEventFetchData>((event, emit) async {
      emit(ChanStateLoading());
      _repository.fetchBoardList(includeNsfw);
    });
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }

  @override
  BoardListStateContent buildContentState({bool lazyLoading = false, ChanSingleEvent? event}) {
    List<ChanBoardItemWrapper> boards = [];
    List<ChanBoardItemWrapper> filteredFavoriteBoards = favoriteBoards
        .where((board) => _matchesQuery(board, searchQuery))
        .map((board) => ChanBoardItemWrapper(chanBoard: board))
        .toList();
    List<ChanBoardItemWrapper> filteredOtherBoards = otherBoards
        .where((board) => _matchesQuery(board, searchQuery))
        .map((board) => ChanBoardItemWrapper(chanBoard: board))
        .toList();
    if (filteredFavoriteBoards.isNotEmpty) {
      boards.add(ChanBoardItemWrapper(headerTitle: "Favorites"));
      boards.addAll(filteredFavoriteBoards);
      if (otherBoards.isNotEmpty) {
        boards.add(ChanBoardItemWrapper(headerTitle: "Others"));
      }
    }
    boards.addAll(filteredOtherBoards);

    return BoardListStateContent(
        boards: boards, showLazyLoading: lazyLoading, showSearchBar: showSearchBar, event: event);
  }

  bool _matchesQuery(BoardItem board, String query) {
    return board.boardId.containsIgnoreCase(query) || board.title.containsIgnoreCase(query);
  }
}
