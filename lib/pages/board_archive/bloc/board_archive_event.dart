import 'package:flutter_chan_viewer/bloc/chan_event.dart';

class BoardArchiveEventFetchDetail extends ChanEvent {
  final int index;

  BoardArchiveEventFetchDetail(this.index);

  @override
  List<Object> get props => [index];
}
