import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';

import 'board_detail_event.dart';
import 'board_detail_state.dart';

class BoardDetailBloc extends Bloc<BoardDetailEvent, BoardDetailState> {
  static const int FIRST_PAGE_INDEX = 1;

  final _repository = ChanRepository.get();

  void initBloc() {}

  @override
  get initialState => BoardDetailStateLoading();

  @override
  Stream<BoardDetailState> mapEventToState(BoardDetailEvent event) async* {
    print("Event received! ${event.toString()}");
    print("Current state! ${state.toString()}");
    try {
      if (event is BoardDetailEventAppStarted) {
        initBloc();
        yield BoardDetailStateLoading();
      }

      if (event is BoardDetailEventFetchThreads) {
        final newThreads = await _repository.fetchBoardDetail(event.boardId);
        yield BoardDetailStateContent(newThreads.threads);
      }
    } catch (o) {
      print("Event error! ${o.toString()}");
      yield BoardDetailStateError(o.toString());
    }
  }
}
