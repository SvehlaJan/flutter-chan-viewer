import 'package:equatable/equatable.dart';

abstract class ChanEvent extends Equatable {
  ChanEvent();

  @override
  List<Object> get props => [];
}

class ChanEventInitBloc extends ChanEvent {}

class ChanEventFetchData extends ChanEvent {
  final bool forceRefresh;

  ChanEventFetchData({this.forceRefresh = false});

  @override
  List<Object> get props => [forceRefresh];
}

class ChanEventNewDataReceived extends ChanEvent {}

class ChanEventSearch extends ChanEvent {
  final String query;

  ChanEventSearch(this.query);

  @override
  List<Object> get props => [query];
}
