import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';

abstract class ThreadDetailState extends Equatable {
  ThreadDetailState();

  @override
  List<Object> get props => [];
}

class ThreadDetailStateLoading extends ThreadDetailState {}

class ThreadDetailStateCloseGallery extends ThreadDetailState {}

class ThreadDetailStateError extends ThreadDetailState {
  final String message;

  ThreadDetailStateError(this.message);

  @override
  String toString() => 'ThreadDetailStateError { message: $message }';

  @override
  List<Object> get props => [message];
}

class ThreadDetailStateShowList extends ThreadDetailState {
  final ThreadDetailModel model;
  final int selectedPostId;
  final bool isFavorite;
  final bool catalogMode;
  final bool lazyLoading;

  ThreadDetailStateShowList(this.model, this.selectedPostId, this.isFavorite, this.catalogMode, this.lazyLoading);

  get selectedMediaIndex => model.getMediaIndex(selectedPostId);

  get selectedPostIndex => model.getPostIndex(selectedPostId);

  @override
  String toString() => 'ThreadDetailStateContent { posts: $model, selectedPostId: $selectedPostId, isFavorite: $isFavorite, catalogMode: $catalogMode, lazyLoading: $lazyLoading }';

  @override
  List<Object> get props => [model, selectedPostId, isFavorite, catalogMode, lazyLoading];
}

class ThreadDetailStateShowGallery extends ThreadDetailState {
  final ThreadDetailModel model;
  final int selectedPostId;

  ThreadDetailStateShowGallery(this.model, this.selectedPostId);

  get selectedMediaIndex => model.getMediaIndex(selectedPostId);

  get selectedPostIndex => model.getPostIndex(selectedPostId);

  @override
  String toString() => 'ThreadDetailStateShowGallery { posts: $model, selectedPostId: $selectedPostId }';

  @override
  List<Object> get props => [model, selectedPostId];
}
