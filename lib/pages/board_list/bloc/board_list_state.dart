import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/models/api/boards_model.dart';

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
  final List<ChanBoard> boards;
  final showOnlyFavorites;

  BoardListStateContent(this.boards, this.showOnlyFavorites)
      : super([
          boards,
          showOnlyFavorites
        ]);

  @override
  String toString() => 'BoardListStateContent { boards: ${boards.length} }';
}
