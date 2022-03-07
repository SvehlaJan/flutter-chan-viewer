import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';
import 'package:flutter_chan_viewer/utils/navigation_helper.dart';

import '../chan_event.dart';
import 'chan_viewer_event.dart';
import 'chan_viewer_state.dart';

class ChanViewerBloc extends Bloc<ChanEvent, ChanState> {
  ChanViewerBloc() : super(ChanViewerStateContent(currentTab: TabItem.boards)) {
    on<ChanViewerEventSelectTab>((event, emit) {
      currentTab = event.selectedTab;
      emit(_buildContentState(currentTab: event.selectedTab));
    });
  }

  TabItem currentTab = TabItem.boards;

  ChanViewerStateContent _buildContentState({TabItem? currentTab, ChanSingleEvent? event}) {
    return ChanViewerStateContent(
      currentTab: currentTab ?? this.currentTab,
      event: event,
    );
  }
}
