import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/board_detail_model.dart';

class BoardDetailStateContent extends ChanState {
  final List<ChanThread> threads;
  final bool lazyLoading;
  final bool isFavorite;

  BoardDetailStateContent(this.threads, this.lazyLoading, this.isFavorite);

  @override
  List<Object> get props => [threads, lazyLoading, isFavorite];
}
