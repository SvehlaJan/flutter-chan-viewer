import 'package:flutter_chan_viewer/bloc/chan_event.dart';

class BoardListEventOnItemClicked extends ChanEvent {
  final String boardId;

  BoardListEventOnItemClicked(this.boardId);

  @override
  List<Object?> get props => [boardId];
}
