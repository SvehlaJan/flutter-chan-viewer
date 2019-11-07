import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/models/posts_model.dart';

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
  final PostsModel data;
  final bool isFavorite;
  final bool catalogMode;

  ThreadDetailStateContent(this.data, this.isFavorite, this.catalogMode) : super([data, isFavorite, catalogMode]);

  @override
  String toString() => 'ThreadDetailStateContent { posts: $data, isFavorite: $isFavorite, catalogMode: $catalogMode }';
}
