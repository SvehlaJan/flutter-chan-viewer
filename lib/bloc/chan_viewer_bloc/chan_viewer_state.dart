import 'package:equatable/equatable.dart';

abstract class ChanViewerState extends Equatable {
  ChanViewerState([List props = const []]) : super(props);
}

class ChanViewerStateError extends ChanViewerState {
  final String message;

  ChanViewerStateError(this.message);

  @override
  String toString() => 'BoardListStateError { message: $message }';
}

class ChanViewerStateContent extends ChanViewerState {
  final showBottomBar;

  ChanViewerStateContent(this.showBottomBar)
      : super([
          showBottomBar,
        ]);

  @override
  String toString() => 'ChanViewerStateContent { showBottomBar: $showBottomBar }';
}
