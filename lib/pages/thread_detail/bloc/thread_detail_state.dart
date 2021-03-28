import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';

class ThreadDetailStateContent extends ChanStateContent {
  final ThreadDetailModel? model;
  final List<ThreadItem> customThreads;
  final int? selectedPostId;
  final bool isFavorite;
  final bool catalogMode;
  final ThreadDetailSingleEvent? event;

  const ThreadDetailStateContent({
    required showSearchBar,
    required showLazyLoading,
    required this.model,
    required this.customThreads,
    required this.selectedPostId,
    required this.isFavorite,
    required this.catalogMode,
    required this.event,
  }) : super(showSearchBar: showSearchBar, showLazyLoading: showLazyLoading);

  get selectedMediaIndex => model?.getMediaIndex(selectedPostId);

  get selectedPostIndex => model?.getPostIndex(selectedPostId);

  @override
  List<Object?> get props => super.props..addAll([model, selectedPostId, isFavorite, catalogMode, event]);
}

enum ThreadDetailSingleEvent {
  SHOW_UNSTAR_WARNING,
  SCROLL_TO_SELECTED,
  CLOSE_PAGE,
  SHOW_OFFLINE,
  SHOW_COLLECTIONS_DIALOG,
  SHOW_POST_ADDED_TO_COLLECTION_SUCCESS,
}
