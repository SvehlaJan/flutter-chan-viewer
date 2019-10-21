import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/models/api/threads_model.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';

import 'board_detail_event.dart';
import 'board_detail_state.dart';

class BoardDetailBloc extends Bloc<BoardDetailEvent, BoardDetailState> {
  static const int FIRST_PAGE_INDEX = 1;

  final _repository = ChanRepository.get();
  int lastPage = 0;
  bool isLazyLoading = false;

  void initBloc() {}

  @override
  get initialState => BoardDetailStateLoading();

  @override
  Stream<BoardDetailState> mapEventToState(BoardDetailEvent event) async* {
    print("Event received! ${event.toString()}");
    print("Current state! ${currentState.toString()}");
    try {
      if (event is BoardDetailEventAppStarted) {
        initBloc();
        yield BoardDetailStateLoading();
      }
      if (event is BoardDetailEventFetchThreads) {
        if (event.page == FIRST_PAGE_INDEX) {
          yield BoardDetailStateLoading();
        } else {
          isLazyLoading = true;
        }

        final List<ChanThread> allThreads = [];
        final newThreads = await _repository.fetchThreads(event.boardId, event.page);

        if (currentState is BoardDetailStateContent && isLazyLoading) {
          allThreads.addAll((currentState as BoardDetailStateContent).threads);
        }
        allThreads.addAll(newThreads.threads);

        lastPage = event.page;
        isLazyLoading = false;
        yield BoardDetailStateContent(allThreads, _hasReachedMax(currentState, newThreads));
      }
    } catch (o) {
      print("Event error! ${o.toString()}");
      isLazyLoading = false;
      yield BoardDetailStateError(o.toString());
    }
  }

  bool _hasReachedMax(BoardDetailState state, ThreadsModel threads) => threads.threads.length < 15 || lastPage >= 10;
}
