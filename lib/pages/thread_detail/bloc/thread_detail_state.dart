import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';

class ThreadDetailStateContent extends ChanState {
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
  List<Object> get props => [model, selectedPostId, showAppBar, isFavorite, catalogMode, lazyLoading, event];
}

enum ThreadDetailSingleEvent {
  SHOW_UNSTAR_WARNING,
  SCROLL_TO_SELECTED,
  CLOSE_PAGE,
  SHOW_OFFLINE,
}
