import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/utils/chan_cache.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';

import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc();

  Future<void> initBloc() async {
    await Preferences.load();
    await ChanCache.init();
    await ChanRepository.init();
  }

  @override
  get initialState => AppStateLoading();

  @override
  Stream<AppState> mapEventToState(AppEvent event) async* {
    print("Event received! ${event.toString()}");
    print("Current state! ${state.toString()}");
    try {
      if (event is AppEventAppStarted) {
        await initBloc();
        int appThemeIndex = Preferences.getInt(Preferences.KEY_SETTINGS_THEME) ?? 0;
        AppTheme appTheme = AppTheme.values[appThemeIndex];
        yield AppStateContent(appTheme);
      }
      if (event is AppEventSetTheme) {
        yield AppStateContent(event.appTheme);
      }
    } catch (o) {
      print("Event error! ${o.toString()}");
      yield AppStateError(o.toString());
    }
  }
}
