import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/models/helper/chan_board_item_wrapper.dart';

abstract class BoardListState extends Equatable {
  BoardListState();
}

class BoardListStateLoading extends BoardListState {
  @override
  String toString() => 'BoardListStateLoading';

  @override
  List<Object> get props => [];
}

class BoardListStateError extends BoardListState {
  final String message;

  BoardListStateError(this.message);

  @override
  String toString() => 'BoardListStateError { message: $message }';

  @override
  List<Object> get props => [message];
}

class BoardListStateContent extends BoardListState {
  final List<ChanBoardItemWrapper> items;

  BoardListStateContent(this.items);

  @override
  String toString() => 'BoardListStateContent { items: ${items.length} }';

  @override
  List<Object> get props => [items];
}
