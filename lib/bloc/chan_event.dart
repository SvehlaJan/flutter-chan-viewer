import 'package:equatable/equatable.dart';

abstract class ChanEvent extends Equatable {
  ChanEvent();

  @override
  List<Object> get props => [];
}

class ChanEventFetchData extends ChanEvent {}

class ChanEventSearch extends ChanEvent {
  final String query;

  ChanEventSearch(this.query);

  @override
  List<Object> get props => [query];
}
