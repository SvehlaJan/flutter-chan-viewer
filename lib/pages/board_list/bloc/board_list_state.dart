import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chan_viewer/models/helper/chan_board_item_wrapper.dart';

@immutable
sealed class BoardListState extends Equatable {
  final bool showSearchBar;
  final BoardListSingleEvent? event;

  BoardListState({
    required this.showSearchBar,
    this.event,
  });

  @override
  List<Object?> get props => [showSearchBar, event];
}

@immutable
class BoardListStateLoading extends BoardListState {
  BoardListStateLoading({
    showSearchBar = false,
    event,
  }) : super(showSearchBar: showSearchBar, event: event);
}

@immutable
class BoardListStateError extends BoardListState {
  final String message;

  BoardListStateError({
    required this.message,
    showSearchBar = false,
    event,
  }) : super(showSearchBar: showSearchBar, event: event);

  @override
  List<Object?> get props => super.props..addAll([message]);
}

@immutable
class BoardListStateContent extends BoardListState {
  final List<ChanBoardItemWrapper> boards;
  final bool showLazyLoading;

  BoardListStateContent({
    required this.boards,
    required this.showLazyLoading,
    required showSearchBar,
    required event,
  }) : super(showSearchBar: showSearchBar, event: event);

  @override
  List<Object?> get props => super.props..addAll([boards, showLazyLoading]);
}

@immutable
abstract class BoardListSingleEvent extends Equatable {
  final int uuid = DateTime.now().millisecondsSinceEpoch;

  @override
  List<Object?> get props => [uuid];
}

@immutable
class BoardListSingleEventShowOffline extends BoardListSingleEvent {}

@immutable
class BoardListSingleEventNavigateToBoard extends BoardListSingleEvent {
  final String boardId;

  BoardListSingleEventNavigateToBoard(this.boardId);

  @override
  List<Object?> get props => super.props..addAll([boardId]);
}