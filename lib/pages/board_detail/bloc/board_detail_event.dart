import 'package:equatable/equatable.dart';

abstract class BoardDetailEvent extends Equatable {
  BoardDetailEvent();
}

class BoardDetailEventToggleFavorite extends BoardDetailEvent {
  @override
  String toString() => 'BoardDetailEventToggleFavorite { }';

  @override
  List<Object> get props => [];
}

class BoardDetailEventFetchThreads extends BoardDetailEvent {
  final bool forceFetch;

  BoardDetailEventFetchThreads(this.forceFetch);

  @override
  String toString() => 'BoardDetailEventFetchThreads { forceFetch: $forceFetch }';

  @override
  List<Object> get props => [forceFetch];
}

class BoardDetailEventSearchBoards extends BoardDetailEvent {
  final String query;

  BoardDetailEventSearchBoards(this.query);

  @override
  String toString() => 'BoardDetailEventSearchBoards { query: $query }';

  @override
  List<Object> get props => [query];
}
