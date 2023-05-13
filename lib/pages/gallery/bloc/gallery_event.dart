import 'package:flutter_chan_viewer/bloc/chan_event.dart';

class GalleryEventOnPostSelected extends ChanEvent {
  final int postId;

  GalleryEventOnPostSelected(this.postId);

  @override
  List<Object?> get props => [postId];
}

class GalleryEventOnReplyClicked extends ChanEvent {
  final int postId;

  GalleryEventOnReplyClicked(this.postId);

  @override
  List<Object?> get props => [postId];
}

class GalleryEventOnLinkClicked extends ChanEvent {
  final String url;

  GalleryEventOnLinkClicked(this.url);

  @override
  List<Object> get props => [url];
}

class GalleryEventHidePost extends ChanEvent {
  final int postId;

  GalleryEventHidePost(this.postId);

  @override
  List<Object?> get props => [postId];
}

class GalleryEventCreateNewCollection extends ChanEvent {
  final String name;

  GalleryEventCreateNewCollection(this.name);

  @override
  List<Object> get props => [name];
}

class GalleryEventAddPostToCollection extends ChanEvent {
  final String name;
  final int postId;

  GalleryEventAddPostToCollection(this.name, this.postId);

  @override
  List<Object> get props => [name, postId];
}
