import 'package:equatable/equatable.dart';

abstract class ChanViewerEvent extends Equatable {
  ChanViewerEvent();
}

class ChanViewerEventShowBottomBar extends ChanViewerEvent {
  final bool showBottomBar;

  ChanViewerEventShowBottomBar(this.showBottomBar);

  @override
  String toString() => 'ChanViewerEventShowBottomBar { showBottomBar: $showBottomBar }';

  @override
  List<Object> get props => [showBottomBar];
}
