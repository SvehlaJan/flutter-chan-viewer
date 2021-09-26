import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/utils/navigation_helper.dart';

class ChanViewerStateContent extends ChanState {
  final TabItem currentTab;

  const ChanViewerStateContent({
    required this.currentTab,
    event,
  }) : super(event: event);

  @override
  List<Object?> get props => super.props..addAll([currentTab]);
}
