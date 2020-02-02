import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';

abstract class FavoritesState extends Equatable {
  FavoritesState();
}

class FavoritesStateLoading extends FavoritesState {
  @override
  String toString() => 'FavoritesStateLoading';

  @override
  List<Object> get props => [];
}

class FavoritesStateError extends FavoritesState {
  final String message;

  FavoritesStateError(this.message);

  @override
  String toString() => 'FavoritesStateError { message: $message }';

  @override
  List<Object> get props => [message];
}

class FavoritesStateContent extends FavoritesState {
  final HashMap<String, List<ThreadDetailModel>> threadMap;

  FavoritesStateContent(this.threadMap);

  @override
  String toString() => 'FavoritesStateContent { threadMap: ${threadMap.length} }';

  @override
  List<Object> get props => [threadMap];
}
