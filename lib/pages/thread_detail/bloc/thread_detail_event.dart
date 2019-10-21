import 'package:equatable/equatable.dart';

abstract class ThreadDetailEvent extends Equatable {
  ThreadDetailEvent([List props = const []]) : super(props);
}

class ThreadDetailEventAppStarted extends ThreadDetailEvent {
  @override
  String toString() => 'ThreadDetailEventAppStarted { }';
}

class ThreadDetailEventFetchPosts extends ThreadDetailEvent {
  final String boardId;
  final int threadId;

  ThreadDetailEventFetchPosts(this.boardId, this.threadId)
      : super([
          boardId,
          threadId
        ]);

  @override
  String toString() => 'ThreadDetailEventFetchThreads { boardId: $boardId, threadId: $threadId }';
}
