import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';

class GalleryStateContent extends ChanStateContent {
  final List<PostItem> posts;
  final PostItem selectedPost;
  final int selectedPostIndex;
  final List<ThreadItem> customThreads;

  const GalleryStateContent({
    required showSearchBar,
    required showLazyLoading,
    required event,
    required this.posts,
    required this.selectedPost,
    required this.selectedPostIndex,
    required this.customThreads,
  }) : super(showSearchBar: showSearchBar, showLazyLoading: showLazyLoading, event: event);

  @override
  List<Object?> get props => super.props..addAll([posts, selectedPostIndex, customThreads]);
}

class GallerySingleEvent extends ChanSingleEvent {
  const GallerySingleEvent(int val) : super(val);

  static const ChanSingleEvent SHOW_COLLECTIONS_DIALOG = const ChanSingleEvent(12);
  static const ChanSingleEvent SHOW_POST_ADDED_TO_COLLECTION_SUCCESS = const ChanSingleEvent(13);
}
