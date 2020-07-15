import 'package:flutter_chan_viewer/bloc/chan_event.dart';

class BoardArchiveEventFetchDetailsLazy extends ChanEvent {}

class BoardArchiveEventFetchDetail extends ChanEvent {
  final int index;

  BoardArchiveEventFetchDetail(this.index);

  @override
  List<Object> get props => [index];
}