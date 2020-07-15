import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';

class BoardArchiveStateContent extends ChanState {
  final List<ArchiveThreadWrapper> threads;
  final bool lazyLoading;

  BoardArchiveStateContent(this.threads, this.lazyLoading);

  @override
  List<Object> get props => [threads, lazyLoading];
}

class ArchiveThreadWrapper extends Equatable {
  final ThreadDetailModel threadDetailModel;
  final bool isLoading;

  ArchiveThreadWrapper(this.threadDetailModel, this.isLoading);

  @override
  List<Object> get props => [threadDetailModel, isLoading];
}
