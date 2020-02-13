import 'package:equatable/equatable.dart';

abstract class ThreadDetailEvent extends Equatable {
  ThreadDetailEvent();

  @override
  List<Object> get props => [];
}

class ThreadDetailEventToggleFavorite extends ThreadDetailEvent {}

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

class ThreadDetailEventFetchPosts extends ThreadDetailEvent {
  final bool forceFetch;

  ThreadDetailEventFetchPosts(this.forceFetch);

  @override
  String toString() => 'ThreadDetailEventFetchThreads { forceFetch: $forceFetch }';

  @override
  List<Object> get props => [forceFetch];
}
