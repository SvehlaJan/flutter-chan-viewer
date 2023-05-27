import 'package:flutter_chan_viewer/bloc/chan_event.dart';

class BoardArchiveEventFetchDetail extends ChanEvent {
  final int index;

  BoardArchiveEventFetchDetail(this.index);

  @override
  List<Object> get props => [index];
}

class BoardArchiveEventOnThreadClicked extends ChanEvent {
  final int threadId;

  BoardArchiveEventOnThreadClicked(this.threadId);

  @override
  List<Object> get props => [threadId];
}