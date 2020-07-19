import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';

import 'chan_viewer_event.dart';
import 'chan_viewer_state.dart';

class ChanViewerBloc extends Bloc<ChanViewerEvent, ChanState> {
  ChanViewerBloc() : super(ChanViewerStateContent());

  @override
  Stream<ChanState> mapEventToState(ChanViewerEvent event) async* {
    try {
    } catch (e, stackTrace) {
      ChanLogger.e("File read error!", e, stackTrace);
      yield ChanStateError(e.toString());
    }
  }
}
