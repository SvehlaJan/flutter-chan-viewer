import 'package:flutter_chan_viewer/bloc/chan_event.dart';

class ThreadDetailEventToggleFavorite extends ChanEvent {
  final bool confirmed;

  ThreadDetailEventToggleFavorite({required this.confirmed});

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
  final int postId;

  ThreadDetailEventOnPostSelected(this.postId);

  @override
  List<Object?> get props => [postId];
}

class ThreadDetailEventOnReplyClicked extends ChanEvent {
  final int postId;

  ThreadDetailEventOnReplyClicked(this.postId);

  @override
  List<Object?> get props => [postId];
}

class ThreadDetailEventHidePost extends ChanEvent {
  final int postId;

  ThreadDetailEventHidePost(this.postId);

  @override
  List<Object?> get props => [postId];
}

class ThreadDetailEventCreateNewCollection extends ChanEvent {
  final String name;

  ThreadDetailEventCreateNewCollection(this.name);

  @override
  List<Object> get props => [name];
}

class ThreadDetailEventDeleteCollection extends ChanEvent {
  final int threadId;

  ThreadDetailEventDeleteCollection(this.threadId);

  @override
  List<Object?> get props => [threadId];
}

class ThreadDetailEventAddPostToCollection extends ChanEvent {
  final String name;
  final int postId;

  ThreadDetailEventAddPostToCollection(this.name, this.postId);

  @override
  List<Object> get props => [name, postId];
}
