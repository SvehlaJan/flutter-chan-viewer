import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item_vo.dart';

@immutable
sealed class BoardArchiveState extends Equatable {
  final BoardArchiveSingleEvent? event;
  final bool showSearchBar;

  BoardArchiveState({
    required this.event,
    required this.showSearchBar,
  });

  @override
  List<Object?> get props => [event, showSearchBar];
}

@immutable
class BoardArchiveStateLoading extends BoardArchiveState {
  BoardArchiveStateLoading({
    BoardArchiveSingleEvent? event,
    showSearchBar = false,
  }) : super(event: event, showSearchBar: showSearchBar);
}

@immutable
class BoardArchiveStateError extends BoardArchiveState {
  final String message;

  BoardArchiveStateError(
    this.message, {
    BoardArchiveSingleEvent? event,
    showSearchBar = false,
  }) : super(event: event, showSearchBar: showSearchBar);

  @override
  List<Object?> get props => super.props..addAll([message]);
}

class BoardArchiveStateContent extends BoardArchiveState {
  final List<ArchiveThreadWrapper> threads;
  final bool showLazyLoading;

  BoardArchiveStateContent({
    required this.threads,
    required this.showLazyLoading,
    required showSearchBar,
    required event,
  }) : super(event: event, showSearchBar: showSearchBar);

  @override
  List<Object?> get props => super.props..addAll([threads, showLazyLoading]);
}

class ArchiveThreadWrapper extends Equatable {
  final ThreadItemVO thread;
  final bool isLoading;

  ArchiveThreadWrapper(this.thread, this.isLoading);

  @override
  List<Object> get props => [thread, isLoading];
}

@immutable
abstract class BoardArchiveSingleEvent extends Equatable {
  final int uuid = DateTime.now().millisecondsSinceEpoch;

  @override
  List<Object?> get props => [uuid];
}

@immutable
class BoardArchiveSingleEventShowOffline extends BoardArchiveSingleEvent {}

@immutable
class BoardArchiveSingleEventNavigateToThread extends BoardArchiveSingleEvent {
  final String boardId;
  final int threadId;

  BoardArchiveSingleEventNavigateToThread(this.boardId, this.threadId);

  @override
  List<Object?> get props => super.props..addAll([boardId, threadId]);
}