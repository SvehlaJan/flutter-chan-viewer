import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/board_list_model.dart';
import 'package:flutter_chan_viewer/models/helper/chan_board_item_wrapper.dart';
import 'package:flutter_chan_viewer/models/ui/board_item_vo.dart';
import 'package:flutter_chan_viewer/pages/board_list/bloc/board_list_event.dart';
import 'package:flutter_chan_viewer/pages/board_list/bloc/board_list_state.dart';
import 'package:flutter_chan_viewer/repositories/boards_repository.dart';
import 'package:flutter_chan_viewer/repositories/chan_result.dart';
import 'package:flutter_chan_viewer/utils/exceptions.dart';
import 'package:flutter_chan_viewer/utils/extensions.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';

class BoardListBloc extends Bloc<ChanEvent, BoardListState> {
  final BoardsRepository _repository = getIt<BoardsRepository>();
  final Preferences _preferences = getIt<Preferences>();
  late List<BoardItemVO> favoriteBoards;
  late List<BoardItemVO> otherBoards;
  bool _showSearchBar = false;
  String searchQuery = "";

  late final StreamSubscription _subscription;

  BoardListBloc() : super(BoardListStateLoading()) {
    bool includeNsfw = _preferences.getBool(Preferences.KEY_SETTINGS_SHOW_NSFW, def: false);
    List<String?> favoriteBoardIds = _preferences.getStringList(Preferences.KEY_FAVORITE_BOARDS);

    _subscription = _repository.fetchAndObserveBoardList(includeNsfw).listen((data) {
      add(ChanEventDataFetched(data));
    }, onError: (e) {
      add(ChanEventDataError(e));
    });

    on<ChanEventInitBloc>((event, emit) async {
      emit(BoardListStateLoading());
    });

    on<ChanEventDataFetched<BoardListModel>>((event, emit) async {
      if (event.result is Loading) {
        BoardListModel? data = (event.result as Loading).data;
        if (data != null) {
          favoriteBoards = data.boards
              .where((board) => favoriteBoardIds.contains(board.boardId))
              .map((e) => e.toBoardItemVO())
              .toList();
          otherBoards = data.boards
              .where((board) => !favoriteBoardIds.contains(board.boardId))
              .map((e) => e.toBoardItemVO())
              .toList();
          emit(buildContentState(lazyLoading: true));
        } else {
          emit(BoardListStateLoading());
        }
      } else if (event.result is Success) {
        BoardListModel data = (event.result as Success).data;
        favoriteBoards = data.boards
            .where((board) => favoriteBoardIds.contains(board.boardId))
            .map((e) => e.toBoardItemVO())
            .toList();
        otherBoards = data.boards
            .where((board) => !favoriteBoardIds.contains(board.boardId))
            .map((e) => e.toBoardItemVO())
            .toList();
        emit(buildContentState());
      }
    });

    on<ChanEventDataError>((event, emit) async {
      if (event.error is HttpException || event.error is SocketException) {
        emit(buildContentState(event: BoardListSingleEventShowOffline()));
      }
    });

    on<ChanEventFetchData>((event, emit) async {
      emit(BoardListStateLoading());
      _repository.fetchBoardList(includeNsfw);
    });

    on<BoardListEventOnItemClicked>((event, emit) async {
      emit(buildContentState(event: BoardListSingleEventNavigateToBoard(event.boardId)));
    });
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }

  BoardListState buildContentState({bool lazyLoading = false, BoardListSingleEvent? event}) {
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
      boards: boards,
      showLazyLoading: lazyLoading,
      showSearchBar: _showSearchBar,
      event: event,
    );
  }

  bool _matchesQuery(BoardItemVO board, String query) {
    return board.boardId.containsIgnoreCase(query) || board.title.containsIgnoreCase(query);
  }
}
