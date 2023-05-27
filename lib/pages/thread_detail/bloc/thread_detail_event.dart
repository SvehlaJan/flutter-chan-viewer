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

class ThreadDetailEventOnPostClicked extends ChanEvent {
  final int postId;

  ThreadDetailEventOnPostClicked(this.postId);

  @override
  List<Object?> get props => [postId];
}

class ThreadDetailEventDeleteThread extends ChanEvent {
  ThreadDetailEventDeleteThread();
}
