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
  BoardDetailEventFetchThreads();

  @override
  String toString() => 'BoardDetailEventFetchThreads{}';

  @override
  List<Object> get props => [];
}

class BoardDetailEventSearchBoards extends BoardDetailEvent {
  final String query;

  BoardDetailEventSearchBoards(this.query);

  @override
  String toString() => 'BoardDetailEventSearchBoards { query: $query }';

  @override
  List<Object> get props => [query];
}
