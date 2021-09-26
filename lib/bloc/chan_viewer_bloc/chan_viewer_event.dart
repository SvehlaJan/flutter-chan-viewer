
import 'package:flutter_chan_viewer/utils/navigation_helper.dart';

import '../chan_event.dart';

class ChanViewerEventSelectTab extends ChanEvent {
  final TabItem currentTab;

  const ChanViewerEventSelectTab({required this.currentTab});

  @override
  List<Object> get props => [currentTab];
}
