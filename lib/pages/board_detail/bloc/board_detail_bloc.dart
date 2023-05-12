import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/board_detail_model.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/pages/base/base_bloc.dart';
import 'package:flutter_chan_viewer/pages/board_detail/bloc/board_detail_event.dart';
import 'package:flutter_chan_viewer/pages/board_detail/bloc/board_detail_state.dart';
import 'package:flutter_chan_viewer/repositories/boards_repository.dart';
import 'package:flutter_chan_viewer/repositories/chan_result.dart';
import 'package:flutter_chan_viewer/utils/exceptions.dart';
import 'package:flutter_chan_viewer/utils/extensions.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';

class BoardDetailBloc extends BaseBloc<ChanEvent, ChanState> {
  final BoardsRepository _repository = getIt<BoardsRepository>();
  final Preferences _preferences = getIt<Preferences>();

  final String boardId;
  BoardDetailModel? _boardDetailModel;
  bool _isFavorite = false;

  late final StreamSubscription _subscription;

  BoardDetailBloc(this.boardId) : super(ChanStateLoading()) {
    List<String> favoriteBoards = _preferences.getStringList(Preferences.KEY_FAVORITE_BOARDS);
    _isFavorite = favoriteBoards.contains(boardId);

    _subscription = _repository.fetchAndObserveBoardDetail(boardId).listen((data) {
      add(ChanEventDataFetched(data));
    }, onError: (e) {
      add(ChanEventDataError(e));
    });

    on<ChanEventInitBloc>((event, emit) async {
      emit(ChanStateLoading());
    });

    on<ChanEventDataFetched>((event, emit) async {
      if (event.result is Loading<BoardDetailModel>) {
        if (event.result.data == null) {
          emit(ChanStateLoading());
        } else {
          _boardDetailModel = event.result.data;
          emit(buildContentState(lazyLoading: true));
        }
      } else if (event.result is Success<BoardDetailModel>) {
        _boardDetailModel = event.result.data;
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
      _repository.fetchRemoteBoardDetail(boardId);
    });

    on<BoardDetailEventToggleFavorite>((event, emit) async {
      _isFavorite = !_isFavorite;
      List<String> favoriteBoards = _preferences.getStringList(Preferences.KEY_FAVORITE_BOARDS);
      favoriteBoards.removeWhere((value) => value == boardId);
      if (_isFavorite) {
        favoriteBoards.add(boardId);
      }
      _preferences.setStringList(Preferences.KEY_FAVORITE_BOARDS, favoriteBoards);
      emit(buildContentState());
    });
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }

  @override
  BoardDetailStateContent buildContentState({bool lazyLoading = false, ChanSingleEvent? event}) {
    List<ThreadItem> threads;
    if (searchQuery.isNotNullNorEmpty) {
      List<ThreadItem> titleMatchThreads = _boardDetailModel!.threads
          .where((thread) => (thread.subtitle ?? "").containsIgnoreCase(searchQuery))
          .toList();
      List<ThreadItem> bodyMatchThreads =
          _boardDetailModel!.threads.where((thread) => (thread.content ?? "").containsIgnoreCase(searchQuery)).toList();
      threads = LinkedHashSet<ThreadItem>.from(titleMatchThreads + bodyMatchThreads).toList();
    } else {
      threads = _boardDetailModel!.threads;
    }

    return BoardDetailStateContent(
      threads: threads,
      showLazyLoading: lazyLoading,
      event: event,
      isFavorite: _isFavorite,
      showSearchBar: showSearchBar,
    );
  }
}
