import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/ui/post_item_vo.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item_vo.dart';
import 'package:flutter_chan_viewer/utils/media_helper.dart';

sealed class GalleryState extends ChanState {
  final GallerySingleEventNew? galleryEvent;

  GalleryState({this.galleryEvent = null});

  @override
  List<Object?> get props => [galleryEvent];
}

class GalleryStateLoading extends GalleryState {}

class GalleryStateError extends GalleryState {
  final String message;

  GalleryStateError(this.message);

  @override
  List<Object?> get props => super.props..addAll([message]);
}

class GalleryStateContent extends GalleryState {
  final List<MediaSource> mediaSources;
  final PostItemVO selectedPost;
  final List<PostItemVO> replies;
  final int initialPostIndex;
  final int selectedPostIndex;

  GalleryStateContent({
    required this.mediaSources,
    required this.selectedPost,
    required this.replies,
    required this.initialPostIndex,
    required this.selectedPostIndex,
    required GallerySingleEventNew? event,
  }) : super(galleryEvent: event);

  @override
  List<Object?> get props => super.props
    ..addAll([
      mediaSources,
      selectedPost,
      replies,
      initialPostIndex,
      selectedPostIndex,
    ]);
}

sealed class GallerySingleEventNew extends Equatable {
  final int uuid = DateTime.now().millisecondsSinceEpoch;

  @override
  List<Object?> get props => [uuid];
}

class GallerySingleEventShowOffline extends GallerySingleEventNew {}

class GallerySingleEventShowCollectionsDialog extends GallerySingleEventNew {
  final List<ThreadItemVO> customThreads;
  final int selectedPostId;

  GallerySingleEventShowCollectionsDialog(this.customThreads, this.selectedPostId);

  @override
  List<Object?> get props => super.props..addAll([customThreads, selectedPostId]);
}

class GallerySingleEventShowPostAddedToCollectionSuccess extends GallerySingleEventNew {}

class GallerySingleEventShowReply extends GallerySingleEventNew {
  final int postId;
  final int threadId;
  final String boardId;

  GallerySingleEventShowReply(this.postId, this.threadId, this.boardId);

  @override
  List<Object?> get props => super.props..addAll([postId, threadId, boardId]);
}
