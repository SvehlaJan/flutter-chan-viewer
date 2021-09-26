import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';
import 'package:flutter_chan_viewer/utils/navigation_helper.dart';

import '../chan_event.dart';
import 'chan_viewer_event.dart';
import 'chan_viewer_state.dart';

class ChanViewerBloc extends Bloc<ChanEvent, ChanState> {
  ChanViewerBloc() : super(ChanViewerStateContent(currentTab: TabItem.boards));

  TabItem currentTab = TabItem.boards;

  @override
  Stream<ChanState> mapEventToState(ChanEvent event) async* {
    try {
      if (event is ChanViewerEventSelectTab) {
        yield _buildContentState(currentTab: event.currentTab);
      }
    } catch (e, stackTrace) {
      ChanLogger.e("Chan viewer bloc error!", e, stackTrace);
      yield ChanStateError(e.toString());
    }
  }

  ChanViewerStateContent _buildContentState({TabItem? currentTab, ChanSingleEvent? event}) {
    return ChanViewerStateContent(
      currentTab: currentTab ?? this.currentTab,
      event: event,
    );
  }
}
