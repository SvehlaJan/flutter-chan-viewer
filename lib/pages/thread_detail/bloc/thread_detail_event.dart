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

class ThreadDetailEventFetchPosts extends ThreadDetailEvent {
  final bool forceFetch;

  ThreadDetailEventFetchPosts(this.forceFetch) : super([forceFetch]);

  @override
  String toString() => 'ThreadDetailEventFetchThreads { forceFetch: $forceFetch }';
}
