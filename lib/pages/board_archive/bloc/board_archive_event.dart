import 'package:equatable/equatable.dart';

abstract class BoardArchiveEvent extends Equatable {
  BoardArchiveEvent();

  @override
  List<Object> get props => [];
}

class BoardArchiveEventFetchThreads extends BoardArchiveEvent {}

class BoardArchiveEventFetchDetailsLazy extends BoardArchiveEvent {}

class BoardArchiveEventFetchDetail extends BoardArchiveEvent {
  final int index;

  BoardArchiveEventFetchDetail(this.index);

  @override
  List<Object> get props => [index];
}

class BoardArchiveEventSearchThreads extends BoardArchiveEvent {
  final String query;

  BoardArchiveEventSearchThreads(this.query);

  @override
  List<Object> get props => [query];
}
