import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chan_viewer/models/ui/post_item_vo.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item_vo.dart';
import 'package:flutter_chan_viewer/utils/media_helper.dart';

@immutable
sealed class GalleryState extends Equatable {
  final GallerySingleEvent? galleryEvent;

  GalleryState({this.galleryEvent = null});

  @override
  List<Object?> get props => [galleryEvent];
}

@immutable
class GalleryStateLoading extends GalleryState {}

@immutable
class GalleryStateError extends GalleryState {
  final String message;

  GalleryStateError(this.message);

  @override
  List<Object?> get props => super.props..addAll([message]);
}

@immutable
class GalleryStateContent extends GalleryState {
  final bool showAsCarousel;
  final List<MediaSource> mediaSources;
  final List<PostItemVO> replies;
  final int initialMediaIndex;
  final String? overlayMetadataText;

  GalleryStateContent({
    required this.showAsCarousel,
    required this.mediaSources,
    required this.replies,
    required this.initialMediaIndex,
    this.overlayMetadataText,
    required GallerySingleEvent? event,
  }) : super(galleryEvent: event);

  @override
  List<Object?> get props =>
      super.props..addAll([showAsCarousel, mediaSources, replies, initialMediaIndex, overlayMetadataText]);
}

@immutable
sealed class GallerySingleEvent extends Equatable {
  final int uuid = DateTime.now().millisecondsSinceEpoch;

  @override
  List<Object?> get props => [uuid];
}

@immutable
class GallerySingleEventShowOffline extends GallerySingleEvent {}

@immutable
class GallerySingleEventShowCollectionsDialog extends GallerySingleEvent {
  final List<ThreadItemVO> customThreads;
  final int postId;

  GallerySingleEventShowCollectionsDialog(this.customThreads, this.postId);

  @override
  List<Object?> get props => super.props..addAll([customThreads, postId]);
}

@immutable
class GallerySingleEventShowPostAddedToCollectionSuccess extends GallerySingleEvent {}

@immutable
class GallerySingleEventShowReply extends GallerySingleEvent {
  final int postId;
  final int threadId;
  final String boardId;

  GallerySingleEventShowReply(this.postId, this.threadId, this.boardId);

  @override
  List<Object?> get props => super.props..addAll([postId, threadId, boardId]);
}
