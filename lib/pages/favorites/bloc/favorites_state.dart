import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';

class FavoritesStateContent extends ChanStateContent {
  final List<FavoritesItemWrapper> threads;

  const FavoritesStateContent({
    required showSearchBar,
    required showLazyLoading,
    required event,
    required this.threads,
  }) : super(showSearchBar: showSearchBar, showLazyLoading: showLazyLoading, event: event);

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

  FavoritesThreadWrapper(this.threadDetailModel, {this.isCustom = false, this.isLoading = false});

  @override
  List<Object> get props => [threadDetailModel, isCustom, isLoading];
}
