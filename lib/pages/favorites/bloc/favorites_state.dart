import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';

class FavoritesStateContent extends ChanState {
  final List<FavoritesThreadWrapper> threads;
  final bool lazyLoading;

  FavoritesStateContent(this.threads, this.lazyLoading);

  @override
  List<Object> get props => [threads, lazyLoading];
}

class FavoritesThreadWrapper extends Equatable {
  final ThreadDetailModel threadDetailModel;
  final bool isLoading;
  final int newReplies;

  FavoritesThreadWrapper(this.threadDetailModel, {this.isLoading = false, this.newReplies = 0});

  @override
  List<Object> get props => [threadDetailModel, isLoading, newReplies];
}
