import 'package:equatable/equatable.dart';

abstract class BoardListEvent extends Equatable {
  BoardListEvent();
}

class BoardListEventFetchBoards extends BoardListEvent {
  BoardListEventFetchBoards();

  @override
  String toString() => 'BoardListEventFetchBoards{}';

  @override
  List<Object> get props => [];
}

class BoardListEventSearchBoards extends BoardListEvent {
  final String query;

  BoardListEventSearchBoards(this.query);

  @override
  String toString() => 'BoardListEventSearchBoards { query: $query }';

  @override
  List<Object> get props => [query];
}
