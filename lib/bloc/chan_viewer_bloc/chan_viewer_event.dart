import 'package:equatable/equatable.dart';

abstract class ChanViewerEvent extends Equatable {
  ChanViewerEvent([List props = const []]) : super(props);
}

class ChanViewerEventShowBottomBar extends ChanViewerEvent {
  final bool showBottomBar;

  ChanViewerEventShowBottomBar(this.showBottomBar);

  @override
  String toString() => 'ChanViewerEventShowBottomBar { showBottomBar: $showBottomBar }';
}