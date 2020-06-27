import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';

abstract class ThreadDetailState extends Equatable {
  ThreadDetailState();

  @override
  List<Object> get props => [];
}

class ThreadDetailStateLoading extends ThreadDetailState {}

class ThreadDetailStateError extends ThreadDetailState {
  final String message;

  ThreadDetailStateError(this.message);

  @override
  String toString() => 'ThreadDetailStateError { message: $message }';

  @override
  List<Object> get props => [message];
}

class ThreadDetailStateContent extends ThreadDetailState {
  final ThreadDetailModel model;
  final int selectedPostId;
  final bool showAppBar;
  final bool isFavorite;
  final bool catalogMode;
  final bool lazyLoading;
  final ThreadDetailSingleEvent event;

  ThreadDetailStateContent(this.model, this.selectedPostId, this.showAppBar, this.isFavorite, this.catalogMode, this.lazyLoading, this.event);

  get selectedMediaIndex => model.getMediaIndex(selectedPostId);

  get selectedPostIndex => model.getPostIndex(selectedPostId);

  @override
  String toString() {
    return 'ThreadDetailStateContent{model: $model, selectedPostId: $selectedPostId, showAppBar: $showAppBar, isFavorite: $isFavorite, catalogMode: $catalogMode, lazyLoading: $lazyLoading, event: $event}';
  }

  @override
  List<Object> get props => [model, selectedPostId, showAppBar, isFavorite, catalogMode, lazyLoading];
}

enum ThreadDetailSingleEvent {
  SHOW_UNSTAR_WARNING,
  SCROLL_TO_SELECTED,
  CLOSE_PAGE,
  SHOW_OFFLINE,
}
