import 'package:flutter_chan_viewer/utils/navigation_helper.dart';

import '../chan_event.dart';

class ChanViewerEventSelectTab extends ChanEvent {
  final TabItem selectedTab;

  const ChanViewerEventSelectTab({required this.selectedTab});

  @override
  List<Object> get props => [selectedTab];
}
