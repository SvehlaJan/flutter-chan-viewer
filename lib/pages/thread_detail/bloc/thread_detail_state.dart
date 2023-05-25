import 'package:flutter/foundation.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/ui/post_item_vo.dart';

@immutable
class ThreadDetailStateContent extends ChanStateContent {
  final List<PostItemVO> posts;
  final int selectedPostIndex;
  final bool isFavorite;
  final bool isCustomThread;
  final bool catalogMode;

  const ThreadDetailStateContent({
    required showSearchBar,
    required showLazyLoading,
    required event,
    required this.posts,
    required this.selectedPostIndex,
    required this.isFavorite,
    required this.isCustomThread,
    required this.catalogMode,
  }) : super(showSearchBar: showSearchBar, showLazyLoading: showLazyLoading, event: event);

  @override
  List<Object?> get props => super.props..addAll([posts, selectedPostIndex, isFavorite, isCustomThread, catalogMode]);
}

class ThreadDetailSingleEvent extends ChanSingleEvent {
  const ThreadDetailSingleEvent(int val) : super(val);

  static const ChanSingleEvent SHOW_UNSTAR_WARNING = const ChanSingleEvent(10);
  static const ChanSingleEvent SCROLL_TO_SELECTED = const ChanSingleEvent(11);
  static const ChanSingleEvent SHOW_COLLECTIONS_DIALOG = const ChanSingleEvent(12);
  static const ChanSingleEvent SHOW_POST_ADDED_TO_COLLECTION_SUCCESS = const ChanSingleEvent(13);
  static const ChanSingleEvent SHOW_GALLERY = const ChanSingleEvent(14);
}
