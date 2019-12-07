import 'package:equatable/equatable.dart';

abstract class BoardDetailEvent extends Equatable {
  BoardDetailEvent();
}

class BoardDetailEventAppStarted extends BoardDetailEvent {
  @override
  String toString() => 'ThreadsEventAppStarted { }';

  @override
  List<Object> get props => [];
}

class BoardDetailEventFetchThreads extends BoardDetailEvent {
  final bool forceFetch;
  final String boardId;

  BoardDetailEventFetchThreads(this.forceFetch, this.boardId);

  @override
  String toString() => 'ThreadsEventFetchBoards { forceFetch: $forceFetch, boardId: $boardId }';

  @override
  List<Object> get props => [forceFetch, boardId];
}
