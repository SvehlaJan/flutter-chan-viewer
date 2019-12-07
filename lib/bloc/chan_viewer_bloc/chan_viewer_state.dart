import 'package:equatable/equatable.dart';

abstract class ChanViewerState extends Equatable {
  ChanViewerState();
}

class ChanViewerStateError extends ChanViewerState {
  final String message;

  ChanViewerStateError(this.message);

  @override
  String toString() => 'BoardListStateError { message: $message }';

  @override
  List<Object> get props => [message];
}

class ChanViewerStateContent extends ChanViewerState {
  final showBottomBar;

  ChanViewerStateContent(this.showBottomBar);

  @override
  String toString() => 'ChanViewerStateContent { showBottomBar: $showBottomBar }';

  @override
  List<Object> get props => [showBottomBar];
}
