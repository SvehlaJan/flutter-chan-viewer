import 'package:equatable/equatable.dart';

abstract class BoardListEvent extends Equatable {
  BoardListEvent();
}

class BoardListEventFetchBoards extends BoardListEvent {
  final bool forceFetch;

  BoardListEventFetchBoards(this.forceFetch);

  @override
  String toString() => 'BoardListEventFetchBoards { forceFetch: $forceFetch }';

  @override
  List<Object> get props => [forceFetch];
}

class BoardListEventSearchBoards extends BoardListEvent {
  final String query;

  BoardListEventSearchBoards(this.query);

  @override
  String toString() => 'BoardListEventSearchBoards { query: $query }';

  @override
  List<Object> get props => [query];
}
