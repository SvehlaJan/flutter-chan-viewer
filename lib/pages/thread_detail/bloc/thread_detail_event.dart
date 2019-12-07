import 'package:equatable/equatable.dart';

abstract class ThreadDetailEvent extends Equatable {
  ThreadDetailEvent([List props = const []]);
}

class ThreadDetailEventToggleFavorite extends ThreadDetailEvent {
  @override
  String toString() => 'ThreadDetailEventToggleFavorite { }';

  @override
  List<Object> get props => [];
}

class ThreadDetailEventToggleCatalogMode extends ThreadDetailEvent {
  @override
  String toString() => 'ThreadDetailEventToggleCatalogMode { }';

  @override
  List<Object> get props => [];
}

class ThreadDetailEventOnPostSelected extends ThreadDetailEvent {
  final int mediaIndex;
  final int postId;

  ThreadDetailEventOnPostSelected(this.mediaIndex, this.postId) : super([mediaIndex, postId]);

  @override
  String toString() => 'ThreadDetailEventOnItemClicked { mediaIndex: $mediaIndex, postId: $postId }';

  @override
  List<Object> get props => [mediaIndex, postId];
}

class ThreadDetailEventFetchPosts extends ThreadDetailEvent {
  final bool forceFetch;

  ThreadDetailEventFetchPosts(this.forceFetch) : super([forceFetch]);

  @override
  String toString() => 'ThreadDetailEventFetchThreads { forceFetch: $forceFetch }';

  @override
  List<Object> get props => [forceFetch];
}
