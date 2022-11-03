import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';

class BoardDetailStateContent extends ChanStateContent {
  final List<ThreadItem> threads;
  final bool isFavorite;

  const BoardDetailStateContent({
    required showSearchBar,
    required showLazyLoading,
    required event,
    required this.threads,
    required this.isFavorite,
  }) : super(showSearchBar: showSearchBar, showLazyLoading: showLazyLoading, event: event);

  @override
  List<Object?> get props => super.props..addAll([threads, isFavorite]);
}
