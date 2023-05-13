import 'package:flutter_chan_viewer/bloc/chan_event.dart';

class ThreadDetailEventToggleFavorite extends ChanEvent {
  final bool confirmed;

  ThreadDetailEventToggleFavorite({required this.confirmed});

  @override
  List<Object> get props => [confirmed];
}

class ThreadDetailEventToggleCatalogMode extends ChanEvent {}

class ThreadDetailEventOnLinkClicked extends ChanEvent {
  final String url;

  ThreadDetailEventOnLinkClicked(this.url);

  @override
  List<Object> get props => [url];
}

class ThreadDetailEventOnPostSelected extends ChanEvent {
  final int postId;

  ThreadDetailEventOnPostSelected(this.postId);

  @override
  List<Object?> get props => [postId];
}

class ThreadDetailEventDeleteCollection extends ChanEvent {
  final int threadId;

  ThreadDetailEventDeleteCollection(this.threadId);

  @override
  List<Object?> get props => [threadId];
}
