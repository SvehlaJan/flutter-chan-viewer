import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';

class FavoritesStateContent extends ChanStateContent {
  final List<FavoritesItemWrapper> threads;

  const FavoritesStateContent({
    required showSearchBar,
    required showLazyLoading,
    required this.threads,
  }) : super(showSearchBar: showSearchBar, showLazyLoading: showLazyLoading);

  @override
  List<Object?> get props => super.props..addAll([threads]);
}

class FavoritesItemWrapper extends Equatable {
  final bool isHeader;
  final FavoritesThreadWrapper? thread;
  final String? headerTitle;

  FavoritesItemWrapper(this.isHeader, this.thread, this.headerTitle);

  @override
  List<Object?> get props => [isHeader, thread, headerTitle];
}

class FavoritesThreadWrapper extends Equatable {
  final ThreadDetailModel threadDetailModel;
  final bool isLoading;
  final bool isCustom;
  final int newReplies;

  FavoritesThreadWrapper(this.threadDetailModel, {this.isCustom = false, this.isLoading = false, this.newReplies = 0});

  @override
  List<Object> get props => [threadDetailModel, isCustom, isLoading, newReplies];
}
