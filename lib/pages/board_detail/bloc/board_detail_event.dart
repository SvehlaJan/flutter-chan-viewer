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
  final int page;

  BoardDetailEventFetchThreads(this.boardId, this.page)
      : super([
          boardId,
          page
        ]);

  @override
  String toString() => 'ThreadsEventFetchBoards { boardId: $boardId, page: $page }';
}
