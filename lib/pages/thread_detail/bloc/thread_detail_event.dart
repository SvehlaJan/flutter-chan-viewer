import 'package:equatable/equatable.dart';

abstract class ThreadDetailEvent extends Equatable {
  ThreadDetailEvent([List props = const []]) : super(props);
}

class ThreadDetailEventAppStarted extends ThreadDetailEvent {
  @override
  String toString() => 'ThreadDetailEventAppStarted { }';
}

class ThreadDetailEventFetchPosts extends ThreadDetailEvent {
  final bool forceFetch;
  final String boardId;
  final int threadId;

  ThreadDetailEventFetchPosts(this.forceFetch, this.boardId, this.threadId) : super([forceFetch, boardId, threadId]);

  @override
  String toString() => 'ThreadDetailEventFetchThreads { forceFetch: $forceFetch, boardId: $boardId, threadId: $threadId }';
}
