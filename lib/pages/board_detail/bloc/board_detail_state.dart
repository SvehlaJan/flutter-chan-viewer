import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item_vo.dart';

@immutable
sealed class BoardDetailState extends Equatable {
  final BoardDetailSingleEvent? boardEvent;
  final bool showSearchBar;

  BoardDetailState(this.boardEvent, this.showSearchBar);

  @override
  List<Object?> get props => [boardEvent, showSearchBar];
}

@immutable
class BoardDetailStateContent extends BoardDetailState {
  final List<ThreadItemVO> threads;
  final bool isFavorite;
  final bool showLazyLoading;

  BoardDetailStateContent({
    required this.threads,
    required this.isFavorite,
    required this.showLazyLoading,
    BoardDetailSingleEvent? boardEvent,
    bool showSearchBar = false,
  }) : super(boardEvent, showSearchBar);

  @override
  List<Object?> get props => super.props..addAll([threads, isFavorite]);
}

@immutable
class BoardDetailStateLoading extends BoardDetailState {
  BoardDetailStateLoading({
    BoardDetailSingleEvent? boardEvent,
    bool showSearchBar = false,
  }) : super(boardEvent, showSearchBar);
}

@immutable
class BoardDetailStateError extends BoardDetailState {
  final String message;

  BoardDetailStateError(
    this.message, {
    BoardDetailSingleEvent? boardEvent,
    bool showSearchBar = false,
  }) : super(boardEvent, showSearchBar);

  @override
  List<Object?> get props => super.props..addAll([message]);
}

@immutable
sealed class BoardDetailSingleEvent extends Equatable {
  final int uuid = DateTime.now().millisecondsSinceEpoch;

  @override
  List<Object?> get props => [uuid];
}

@immutable
class BoardDetailEventShowOffline extends BoardDetailSingleEvent {}

@immutable
class BoardDetailEventClosePage extends BoardDetailSingleEvent {}

@immutable
class BoardDetailEventOpenThreadDetail extends BoardDetailSingleEvent {
  final String boardId;
  final int threadId;

  BoardDetailEventOpenThreadDetail(this.boardId, this.threadId);

  @override
  List<Object?> get props => super.props..addAll([boardId, threadId]);
}