import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';

class ThreadDetailEventToggleFavorite extends ChanEvent {}

class ThreadDetailEventDialogAnswered extends ChanEvent {
  final bool confirmed;

  ThreadDetailEventDialogAnswered(this.confirmed);

  @override
  List<Object> get props => [confirmed];
}

class ThreadDetailEventToggleCatalogMode extends ChanEvent {}

class ThreadDetailEventShowDownloaded extends ChanEvent {}

class ThreadDetailEventOnLinkClicked extends ChanEvent {
  final String url;

  ThreadDetailEventOnLinkClicked(this.url);

  @override
  List<Object> get props => [url];
}

class ThreadDetailEventOnPostSelected extends ChanEvent {
  final int mediaIndex;
  final int postId;

  ThreadDetailEventOnPostSelected(this.mediaIndex, this.postId);

  @override
  List<Object> get props => [mediaIndex, postId];
}

class ThreadDetailEventOnReplyClicked extends ChanEvent {
  final int postId;

  ThreadDetailEventOnReplyClicked(this.postId);

  @override
  List<Object> get props => [postId];
}

class ThreadDetailEventOnDataReceived extends ChanEvent {
  final ThreadDetailModel model;

  ThreadDetailEventOnDataReceived(this.model);

  @override
  List<Object> get props => [model];
}
