import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/utils/chan_cache.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';

import 'chan_viewer_event.dart';
import 'chan_viewer_state.dart';

class ChanViewerBloc extends Bloc<ChanViewerEvent, ChanViewerState> {
  ChanViewerBloc();

  @override
  get initialState => ChanViewerStateContent(true);

  @override
  Stream<ChanViewerState> mapEventToState(ChanViewerEvent event) async* {
    print("Event received! ${event.toString()}");
    print("Current state! ${state.toString()}");
    try {
      if (event is ChanViewerEventShowBottomBar) {
        yield ChanViewerStateContent(event.showBottomBar);
      }
    } catch (o) {
      print("Event error! ${o.toString()}");
      yield ChanViewerStateError(o.toString());
    }
  }
}
