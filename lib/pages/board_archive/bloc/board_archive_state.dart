import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';

abstract class BoardArchiveState extends Equatable {
  BoardArchiveState();

  @override
  List<Object> get props => [];
}

class BoardArchiveStateLoading extends BoardArchiveState {}

class BoardArchiveStateError extends BoardArchiveState {
  final String message;

  BoardArchiveStateError(this.message);

  @override
  List<Object> get props => [message];
}

class BoardArchiveStateContent extends BoardArchiveState {
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
