import 'package:flutter_chan_viewer/bloc/chan_event.dart';

class BoardDetailEventToggleFavorite extends ChanEvent {}

class BoardDetailEventOnItemClicked extends ChanEvent {
  final int threadId;

  BoardDetailEventOnItemClicked(this.threadId);

  @override
  List<Object?> get props => [threadId];
}
