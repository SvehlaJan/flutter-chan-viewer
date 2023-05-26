import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item_vo.dart';

class BoardArchiveStateContent extends ChanStateContent {
  final List<ArchiveThreadWrapper> threads;

  const BoardArchiveStateContent({
    required showSearchBar,
    required showLazyLoading,
    required event,
    required this.threads,
  }) : super(
          showSearchBar: showSearchBar,
          showLazyLoading: showLazyLoading,
          event: event,
        );

  @override
  List<Object?> get props => super.props..addAll([threads]);
}

class ArchiveThreadWrapper extends Equatable {
  final ThreadItemVO thread;
  final bool isLoading;

  ArchiveThreadWrapper(this.thread, this.isLoading);

  @override
  List<Object> get props => [thread, isLoading];
}
