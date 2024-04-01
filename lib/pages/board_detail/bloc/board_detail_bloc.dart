import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/board_detail_model.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item_vo.dart';
import 'package:flutter_chan_viewer/pages/board_detail/bloc/board_detail_event.dart';
import 'package:flutter_chan_viewer/pages/board_detail/bloc/board_detail_state.dart';
import 'package:flutter_chan_viewer/repositories/boards_repository.dart';
import 'package:flutter_chan_viewer/repositories/chan_result.dart';
import 'package:flutter_chan_viewer/utils/exceptions.dart';
import 'package:flutter_chan_viewer/utils/extensions.dart';
import 'package:flutter_chan_viewer/utils/media_helper.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';

class BoardDetailBloc extends Bloc<ChanEvent, BoardDetailState> {
  final BoardsRepository _repository = getIt<BoardsRepository>();
  final Preferences _preferences = getIt<Preferences>();
  final MediaHelper _mediaHelper = getIt<MediaHelper>();

  final String boardId;
  BoardDetailModel? _boardDetailModel;
  bool _isFavorite = false;
  bool _showSearchBar = false;
  String searchQuery = "";

  late final StreamSubscription _subscription;

  BoardDetailBloc(this.boardId) : super(BoardDetailStateLoading()) {
    List<String> favoriteBoards = _preferences.getStringList(Preferences.KEY_FAVORITE_BOARDS);
    _isFavorite = favoriteBoards.contains(boardId);

    _subscription = _repository.fetchAndObserveBoardDetail(boardId).listen((data) {
      add(ChanEventDataFetched(data));
    }, onError: (e) {
      add(ChanEventDataError(e));
    });

    on<ChanEventInitBloc>((event, emit) async {
      emit(BoardDetailStateLoading());
    });

    on<ChanEventDataFetched>((event, emit) async {
      if (event.result is Loading<BoardDetailModel>) {
        if (event.result.data == null) {
          emit(BoardDetailStateLoading());
        } else {
          _boardDetailModel = event.result.data;
          emit(await buildContentState(lazyLoading: true));
        }
      } else if (event.result is Success<BoardDetailModel>) {
        _boardDetailModel = event.result.data;
        emit(await buildContentState());
      } else if (event.result is Failure<BoardDetailModel>) {
        Exception exception = (event.result as Failure).exception;
        if (exception is HttpException || exception is SocketException) {
          emit(await buildContentState(event: BoardDetailEventShowOffline()));
        } else {
          emit(BoardDetailStateError(exception.toString()));
        }
      }
    });

    on<ChanEventDataError>((event, emit) async {
      if (event.error is HttpException || event.error is SocketException) {
        emit(await buildContentState(event: BoardDetailEventShowOffline()));
      } else {
        emit(BoardDetailStateError(event.error.toString()));
      }
    });

    on<ChanEventFetchData>((event, emit) async {
      emit(BoardDetailStateLoading());
      _repository.fetchRemoteBoardDetail(boardId);
    });

    on<BoardDetailEventOnItemClicked>((event, emit) async {
      emit(await buildContentState(event: BoardDetailEventOpenThreadDetail(boardId, event.threadId)));
    });

    on<BoardDetailEventToggleFavorite>((event, emit) async {
      _isFavorite = !_isFavorite;
      List<String> favoriteBoards = _preferences.getStringList(Preferences.KEY_FAVORITE_BOARDS);
      favoriteBoards.removeWhere((value) => value == boardId);
      if (_isFavorite) {
        favoriteBoards.add(boardId);
      }
      _preferences.setStringList(Preferences.KEY_FAVORITE_BOARDS, favoriteBoards);
      emit(await buildContentState());
    });

    on<ChanEventSearch>((event, emit) async {
      searchQuery = event.query;
      emit(await buildContentState());
    });

    on<ChanEventShowSearch>((event, emit) async {
      _showSearchBar = true;
      emit(await buildContentState());
    });

    on<ChanEventCloseSearch>((event, emit) async {
      searchQuery = "";
      _showSearchBar = false;
      emit(await buildContentState());
    });
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }

  Future<BoardDetailStateContent> buildContentState({bool lazyLoading = false, BoardDetailSingleEvent? event}) async {
    List<ThreadItemVO> threads;
    if (searchQuery.isNotEmpty) {
      List<ThreadItem> titleMatchThreads = _boardDetailModel!.threads
          .where((thread) => (thread.subtitle ?? "").containsIgnoreCase(searchQuery))
          .toList();
      List<ThreadItem> bodyMatchThreads =
          _boardDetailModel!.threads.where((thread) => (thread.content ?? "").containsIgnoreCase(searchQuery)).toList();
      threads = await LinkedHashSet<ThreadItem>.from(titleMatchThreads + bodyMatchThreads)
          .toList()
          .toThreadItemVOList(_mediaHelper);
    } else {
      threads = await _boardDetailModel!.threads.toThreadItemVOList(_mediaHelper);
    }

    return BoardDetailStateContent(
      threads: threads,
      showLazyLoading: lazyLoading,
      boardEvent: event,
      isFavorite: _isFavorite,
      showSearchBar: _showSearchBar,
    );
  }
}
