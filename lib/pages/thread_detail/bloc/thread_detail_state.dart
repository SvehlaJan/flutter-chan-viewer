import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';

class ThreadDetailStateContent extends ChanStateContent {
  final ThreadDetailModel? model;
  final List<ThreadItem> customThreads;
  final int? selectedPostId;
  final bool isFavorite;
  final bool catalogMode;

  const ThreadDetailStateContent({
    required showSearchBar,
    required showLazyLoading,
    required event,
    required this.model,
    required this.customThreads,
    required this.selectedPostId,
    required this.isFavorite,
    required this.catalogMode,
  }) : super(showSearchBar: showSearchBar, showLazyLoading: showLazyLoading, event: event);

  get selectedMediaIndex => model?.getMediaIndex(selectedPostId);

  get selectedPostIndex => model?.getPostIndex(selectedPostId);

  @override
  List<Object?> get props => super.props..addAll([model, selectedPostId, isFavorite, catalogMode]);
}

class ThreadDetailSingleEvent extends ChanSingleEvent {
  const ThreadDetailSingleEvent(int val) : super(val);

  static const ChanSingleEvent SHOW_UNSTAR_WARNING = const ChanSingleEvent(10);
  static const ChanSingleEvent SCROLL_TO_SELECTED = const ChanSingleEvent(11);
  static const ChanSingleEvent SHOW_COLLECTIONS_DIALOG = const ChanSingleEvent(12);
  static const ChanSingleEvent SHOW_POST_ADDED_TO_COLLECTION_SUCCESS = const ChanSingleEvent(13);
}
