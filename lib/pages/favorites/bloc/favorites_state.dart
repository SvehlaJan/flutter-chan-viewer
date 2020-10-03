import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';

class FavoritesStateContent extends ChanState {
  final List<FavoritesItemWrapper> items;
  final bool lazyLoading;

  FavoritesStateContent(this.items, this.lazyLoading);

  @override
  List<Object> get props => [items, lazyLoading];
}

class FavoritesItemWrapper extends Equatable {
  final bool isHeader;
  final FavoritesThreadWrapper thread;
  final String headerTitle;

  FavoritesItemWrapper(this.isHeader, this.thread, this.headerTitle);

  @override
  List<Object> get props => [isHeader, thread, headerTitle];
}

class FavoritesThreadWrapper extends Equatable {
  final ThreadDetailModel threadDetailModel;
  final bool isLoading;
  final int newReplies;

  FavoritesThreadWrapper(this.threadDetailModel, {this.isLoading = false, this.newReplies = 0});

  @override
  List<Object> get props => [threadDetailModel, isLoading, newReplies];
}
