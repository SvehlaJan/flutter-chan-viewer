import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';

import 'thread_detail_event.dart';
import 'thread_detail_state.dart';

class ThreadDetailBloc extends Bloc<ThreadDetailEvent, ThreadDetailState> {
  final _repository = ChanRepository.get();

  void initBloc() {}

  @override
  get initialState => ThreadDetailStateLoading();

  @override
  Stream<ThreadDetailState> mapEventToState(ThreadDetailEvent event) async* {
    print("Event received! ${event.toString()}");
    print("Current state! ${currentState.toString()}");
    try {
      if (event is ThreadDetailEventAppStarted) {
        initBloc();
        yield ThreadDetailStateLoading();
      }
      if (event is ThreadDetailEventFetchPosts) {
        final posts = await _repository.fetchPosts(event.forceFetch, event.boardId, event.threadId);
        yield ThreadDetailStateContent(posts);
      }
    } catch (o) {
      print("Event error! ${o.toString()}");
      yield ThreadDetailStateError(o.toString());
    }
  }
}
