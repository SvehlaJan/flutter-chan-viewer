import 'package:flutter_chan_viewer/bloc/chan_event.dart';

sealed class GalleryEvent extends ChanEvent {}

class GalleryEventOnPostSelected extends GalleryEvent {
  final int postId;

  GalleryEventOnPostSelected(this.postId);

  @override
  List<Object?> get props => [postId];
}

class GalleryEventOnReplyClicked extends GalleryEvent {
  final int postId;

  GalleryEventOnReplyClicked(this.postId);

  @override
  List<Object?> get props => [postId];
}

class GalleryEventOnLinkClicked extends GalleryEvent {
  final String url;

  GalleryEventOnLinkClicked(this.url);

  @override
  List<Object> get props => [url];
}

class GalleryEventHidePost extends GalleryEvent {
  final int postId;

  GalleryEventHidePost(this.postId);

  @override
  List<Object?> get props => [postId];
}

class GalleryEventCreateNewCollection extends GalleryEvent {
  final String name;

  GalleryEventCreateNewCollection(this.name);

  @override
  List<Object> get props => [name];
}

class GalleryEventAddPostToCollection extends GalleryEvent {
  final String customThreadName;
  final int postId;

  GalleryEventAddPostToCollection(this.customThreadName, this.postId);

  @override
  List<Object> get props => [customThreadName, postId];
}
