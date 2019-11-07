import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/utils/chan_cache.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';

import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc();

  Future<void> initBloc() async {
    await Preferences.load();
    await ChanCache.init();
  }

  @override
  get initialState => AppStateLoading();

  @override
  Stream<AppState> mapEventToState(AppEvent event) async* {
    print("Event received! ${event.toString()}");
    print("Current state! ${currentState.toString()}");
    try {
      if (event is AppEventAppStarted) {
        await initBloc();
        yield AppStateContent(true);
      }
      if (event is AppEventShowBottomBar) {
        yield AppStateContent(event.showBottomBar);
      }
    } catch (o) {
      print("Event error! ${o.toString()}");
      yield AppStateError(o.toString());
    }
  }
}
