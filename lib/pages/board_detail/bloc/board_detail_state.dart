import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/models/board_detail_model.dart';

abstract class BoardDetailState extends Equatable {
  BoardDetailState();
}

class BoardDetailStateLoading extends BoardDetailState {
  @override
  String toString() => 'BoardDetailStateLoading';

  @override
  List<Object> get props => [];
}

class BoardDetailStateError extends BoardDetailState {
  final String message;

  BoardDetailStateError(this.message);

  @override
  String toString() => 'BoardDetailStateError { message: $message }';

  @override
  List<Object> get props => [message];
}

class BoardDetailStateContent extends BoardDetailState {
  final List<ChanThread> threads;
  final bool isFavorite;

  BoardDetailStateContent(this.threads, this.isFavorite);

  @override
  String toString() => 'BoardDetailStateContent { threads: ${threads.length}, isFavorite: $isFavorite }';

  @override
  List<Object> get props => [threads, isFavorite];
}
