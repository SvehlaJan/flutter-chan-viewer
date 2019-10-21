import 'package:equatable/equatable.dart';

abstract class BoardListEvent extends Equatable {
  BoardListEvent([List props = const []]) : super(props);
}

class BoardListEventAppStarted extends BoardListEvent {
  @override
  String toString() => 'BoardListEventAppStarted { }';
}

class BoardListEventFetchBoards extends BoardListEvent {
  @override
  String toString() => 'BoardListEventFetchBoards { }';
}