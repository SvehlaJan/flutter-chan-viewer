import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';

import 'chan_viewer_event.dart';
import 'chan_viewer_state.dart';

class ChanViewerBloc extends Bloc<ChanViewerEvent, ChanViewerState> {
  ChanViewerBloc();

  @override
  get initialState => ChanViewerStateContent(true);

  @override
  Stream<ChanViewerState> mapEventToState(ChanViewerEvent event) async* {
    try {
      if (event is ChanViewerEventShowBottomBar) {
        yield ChanViewerStateContent(event.showBottomBar);
      }
    } catch (e) {
      ChanLogger.e("File read error!", e);
      yield ChanViewerStateError(e.toString());
    }
  }
}
