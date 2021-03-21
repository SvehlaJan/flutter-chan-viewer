import 'package:flutter/foundation.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';

class BoardDetailStateContent extends ChanStateContent {
  final List<ThreadItem> threads;
  final bool isFavorite;

  const BoardDetailStateContent({
    required showSearchBar,
    required showLazyLoading,
    required this.threads,
    required this.isFavorite,
  }) : super(showSearchBar: showSearchBar, showLazyLoading: showLazyLoading);

  @override
  List<Object?> get props => super.props..addAll([threads, isFavorite]);
}
