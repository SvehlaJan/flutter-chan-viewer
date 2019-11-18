import 'package:equatable/equatable.dart';

abstract class ThreadDetailEvent extends Equatable {
  ThreadDetailEvent([List props = const []]) : super(props);
}

class ThreadDetailEventToggleFavorite extends ThreadDetailEvent {
  @override
  String toString() => 'ThreadDetailEventToggleFavorite { }';
}

class ThreadDetailEventToggleCatalogMode extends ThreadDetailEvent {
  @override
  String toString() => 'ThreadDetailEventToggleCatalogMode { }';
}

//class ThreadDetailEventOnPostSelected extends ThreadDetailEvent {
//  final int mediaIndex;
//  final int postId;
//
//  ThreadDetailEventOnPostSelected(this.mediaIndex, this.postId) : super([mediaIndex, postId]);
//
//  @override
//  String toString() => 'ThreadDetailEventOnItemClicked { mediaIndex: $mediaIndex, postId: $postId }';
//}

class ThreadDetailEventFetchPosts extends ThreadDetailEvent {
  final bool forceFetch;

  ThreadDetailEventFetchPosts(this.forceFetch) : super([forceFetch]);

  @override
  String toString() => 'ThreadDetailEventFetchThreads { forceFetch: $forceFetch }';
}
