import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/models/api/threads_model.dart';

abstract class BoardDetailState extends Equatable {
  BoardDetailState([List props = const []]) : super(props);
}

class BoardDetailStateLoading extends BoardDetailState {
  @override
  String toString() => 'BoardDetailStateLoading';
}

class BoardDetailStateError extends BoardDetailState {
  final String message;

  BoardDetailStateError(this.message);

  @override
  String toString() => 'BoardDetailStateError { message: $message }';
}

class BoardDetailStateContent extends BoardDetailState {
  final List<ChanThread> threads;
  final bool hasReachedMax;

  BoardDetailStateContent(this.threads, this.hasReachedMax)
      : super([
          threads,
          hasReachedMax
        ]);

  @override
  String toString() => 'BoardDetailStateContent { threads: ${threads.length}, hasReachedMax: $hasReachedMax }';
}
