import 'package:equatable/equatable.dart';

abstract class BoardDetailEvent extends Equatable {
  BoardDetailEvent([List props = const []]) : super(props);
}

class BoardDetailEventAppStarted extends BoardDetailEvent {
  @override
  String toString() => 'ThreadsEventAppStarted { }';
}

class BoardDetailEventFetchThreads extends BoardDetailEvent {
  final String boardId;

  BoardDetailEventFetchThreads(this.boardId)
      : super([
          boardId
        ]);

  @override
  String toString() => 'ThreadsEventFetchBoards { boardId: $boardId }';
}
