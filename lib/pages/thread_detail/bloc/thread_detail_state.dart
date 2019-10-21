import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/models/api/posts_model.dart';

abstract class ThreadDetailState extends Equatable {
  ThreadDetailState([List props = const []]) : super(props);
}

class ThreadDetailStateLoading extends ThreadDetailState {
  @override
  String toString() => 'ThreadDetailStateLoading';
}

class ThreadDetailStateError extends ThreadDetailState {
  final String message;

  ThreadDetailStateError(this.message);

  @override
  String toString() => 'ThreadDetailStateError { message: $message }';
}

class ThreadDetailStateContent extends ThreadDetailState {
  final List<ChanPost> posts;

  ThreadDetailStateContent(this.posts)
      : super([
          posts
        ]);

  @override
  String toString() => 'ThreadDetailStateContent { posts: ${posts.length} }';
}
