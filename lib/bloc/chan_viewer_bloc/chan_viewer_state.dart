import 'package:equatable/equatable.dart';

abstract class ChanViewerState extends Equatable {
  ChanViewerState();

  @override
  List<Object> get props => [];
}

class ChanViewerStateError extends ChanViewerState {
  final String message;

  ChanViewerStateError(this.message);

  @override
  String toString() => 'BoardListStateError { message: $message }';

  @override
  List<Object> get props => [message];
}

class ChanViewerStateContent extends ChanViewerState {}
