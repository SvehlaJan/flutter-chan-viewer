import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item_vo.dart';

@immutable
sealed class FavoritesState extends Equatable {
  final FavoritesSingleEvent? event;
  final bool showSearchBar;

  FavoritesState({
    required this.event,
    required this.showSearchBar,
  });

  @override
  List<Object?> get props => [event, showSearchBar];
}

@immutable
class FavoritesStateLoading extends FavoritesState {
  FavoritesStateLoading({
    FavoritesSingleEvent? event,
    showSearchBar = false,
  }) : super(event: event, showSearchBar: showSearchBar);
}

@immutable
class FavoritesStateError extends FavoritesState {
  final String message;

  FavoritesStateError(
    this.message, {
    FavoritesSingleEvent? event,
    showSearchBar = false,
  }) : super(event: event, showSearchBar: showSearchBar);

  @override
  List<Object?> get props => super.props..addAll([message]);
}

@immutable
class FavoritesStateContent extends FavoritesState {
  final List<FavoritesItemWrapper> threads;
  final bool showLazyLoading;

  FavoritesStateContent({
    required this.threads,
    required this.showLazyLoading,
    required showSearchBar,
    required event,
  }) : super(showSearchBar: showSearchBar, event: event);

  @override
  List<Object?> get props => super.props..addAll([threads, showLazyLoading]);
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
  final ThreadItemVO thread;
  final bool isLoading;
  final bool isCustom;

  FavoritesThreadWrapper(this.thread, {this.isCustom = false, this.isLoading = false});

  @override
  List<Object> get props => [thread, isCustom, isLoading];
}

@immutable
abstract class FavoritesSingleEvent extends Equatable {
  final int uuid = DateTime.now().millisecondsSinceEpoch;

  @override
  List<Object?> get props => [uuid];
}

@immutable
class FavoritesSingleEventShowOffline extends FavoritesSingleEvent {}

@immutable
class FavoritesSingleEventNavigateToThread extends FavoritesSingleEvent {
  final String boardId;
  final int threadId;

  FavoritesSingleEventNavigateToThread(this.boardId, this.threadId);

  @override
  List<Object?> get props => super.props..addAll([boardId, threadId]);
}
