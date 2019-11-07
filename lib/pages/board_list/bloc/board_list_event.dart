import 'package:equatable/equatable.dart';

abstract class BoardListEvent extends Equatable {
  BoardListEvent([List props = const []]) : super(props);
}

class BoardListEventFetchBoards extends BoardListEvent {
  @override
  String toString() => 'BoardListEventFetchBoards { }';
}