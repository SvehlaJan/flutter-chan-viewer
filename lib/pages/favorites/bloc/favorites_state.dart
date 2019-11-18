import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/models/board_list_model.dart';
import 'package:flutter_chan_viewer/models/board_detail_model.dart';

abstract class FavoritesState extends Equatable {
  FavoritesState([List props = const []]) : super(props);
}

class FavoritesStateLoading extends FavoritesState {
  @override
  String toString() => 'FavoritesStateLoading';
}

class FavoritesStateError extends FavoritesState {
  final String message;

  FavoritesStateError(this.message);

  @override
  String toString() => 'FavoritesStateError { message: $message }';
}

class FavoritesStateContent extends FavoritesState {
  final List<ChanBoard> boards;
  final List<ChanThread> threads;

  FavoritesStateContent(this.boards, this.threads) : super([boards, threads]);

  @override
  String toString() => 'FavoritesStateContent { boards: ${boards.length} threads: ${threads.length} }';
}
