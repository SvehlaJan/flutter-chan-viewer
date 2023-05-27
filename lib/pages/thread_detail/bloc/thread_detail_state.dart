import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chan_viewer/models/ui/post_item_vo.dart';

@immutable
sealed class ThreadDetailState extends Equatable {
  final ThreadDetailSingleEvent? detailEvent;
  final bool showSearchBar;

  ThreadDetailState(this.detailEvent, this.showSearchBar);

  @override
  List<Object?> get props => [detailEvent, showSearchBar];
}

@immutable
class ThreadDetailStateLoading extends ThreadDetailState {
  ThreadDetailStateLoading({
    ThreadDetailSingleEvent? detailEvent,
    bool showSearchBar = false,
  }) : super(detailEvent, showSearchBar);
}

@immutable
class ThreadDetailStateError extends ThreadDetailState {
  final String message;

  ThreadDetailStateError(
    this.message, {
    ThreadDetailSingleEvent? detailEvent,
    bool showSearchBar = false,
  }) : super(detailEvent, showSearchBar);

  @override
  List<Object?> get props => super.props..addAll([message]);
}

@immutable
class ThreadDetailStateContent extends ThreadDetailState {
  final bool showLazyLoading;
  final List<PostItemVO> posts;
  final int selectedPostIndex;
  final bool isFavorite;
  final bool isCustomThread;
  final bool catalogMode;

  ThreadDetailStateContent({
    required this.showLazyLoading,
    required this.posts,
    required this.selectedPostIndex,
    required this.isFavorite,
    required this.isCustomThread,
    required this.catalogMode,
    ThreadDetailSingleEvent? event,
    bool showSearchBar = false,
  }) : super(event, showSearchBar);

  @override
  List<Object?> get props => super.props
    ..addAll([
      showLazyLoading,
      posts,
      selectedPostIndex,
      isFavorite,
      isCustomThread,
      catalogMode,
    ]);
}

sealed class ThreadDetailSingleEvent extends Equatable {
  final int uuid = DateTime.now().millisecondsSinceEpoch;

  @override
  List<Object?> get props => [uuid];
}

class ThreadDetailSingleEventShowUnstarWarning extends ThreadDetailSingleEvent {}

class ThreadDetailSingleEventScrollToSelected extends ThreadDetailSingleEvent {}

class ThreadDetailSingleEventOpenGallery extends ThreadDetailSingleEvent {
  final int postId;
  final int threadId;
  final String boardId;

  ThreadDetailSingleEventOpenGallery(this.postId, this.threadId, this.boardId);

  @override
  List<Object?> get props => super.props..addAll([postId, threadId, boardId]);
}

class ThreadDetailSingleEventClosePage extends ThreadDetailSingleEvent {}

class ThreadDetailSingleEventShowOffline extends ThreadDetailSingleEvent {}
