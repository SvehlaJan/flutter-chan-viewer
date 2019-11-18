import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/models/board_list_model.dart';

abstract class BoardListState extends Equatable {
  BoardListState([List props = const []]) : super(props);
}

class BoardListStateLoading extends BoardListState {
  @override
  String toString() => 'BoardListStateLoading';
}

class BoardListStateError extends BoardListState {
  final String message;

  BoardListStateError(this.message);

  @override
  String toString() => 'BoardListStateError { message: $message }';
}

class BoardListStateContent extends BoardListState {
  final List<ChanBoard> favoriteBoards;
  final List<ChanBoard> otherBoards;

  BoardListStateContent(this.favoriteBoards, this.otherBoards) : super([favoriteBoards, otherBoards]);

  @override
  String toString() => 'BoardListStateContent { favoriteBoards: ${favoriteBoards.length} otherBoards: ${otherBoards.length} }';
}
