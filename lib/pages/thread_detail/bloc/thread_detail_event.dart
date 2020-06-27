import 'package:equatable/equatable.dart';

abstract class ThreadDetailEvent extends Equatable {
  ThreadDetailEvent();

  @override
  List<Object> get props => [];
}

class ThreadDetailEventToggleFavorite extends ThreadDetailEvent {}

class ThreadDetailEventDialogAnswered extends ThreadDetailEvent {
  final bool confirmed;

  ThreadDetailEventDialogAnswered(this.confirmed);

  @override
  List<Object> get props => [confirmed];
}

class ThreadDetailEventToggleCatalogMode extends ThreadDetailEvent {}

class ThreadDetailEventDownload extends ThreadDetailEvent {}

class ThreadDetailEventShowDownloaded extends ThreadDetailEvent {}

class ThreadDetailEventOnLinkClicked extends ThreadDetailEvent {
  final String url;

  ThreadDetailEventOnLinkClicked(this.url);

  @override
  List<Object> get props => [url];
}

class ThreadDetailEventOnPostSelected extends ThreadDetailEvent {
  final int mediaIndex;
  final int postId;

  ThreadDetailEventOnPostSelected(this.mediaIndex, this.postId);

  @override
  String toString() => 'ThreadDetailEventOnPostSelected { mediaIndex: $mediaIndex, postId: $postId }';

  @override
  List<Object> get props => [mediaIndex, postId];
}

class ThreadDetailEventOnReplyClicked extends ThreadDetailEvent {
  final int postId;

  ThreadDetailEventOnReplyClicked(this.postId);

  @override
  String toString() => 'ThreadDetailEventOnReplyClicked { post: $postId }';

  @override
  List<Object> get props => [postId];
}

class ThreadDetailEventFetchPosts extends ThreadDetailEvent {
  final bool forceFetch;

  ThreadDetailEventFetchPosts(this.forceFetch);

  @override
  String toString() => 'ThreadDetailEventFetchThreads { forceFetch: $forceFetch }';

  @override
  List<Object> get props => [forceFetch];
}
