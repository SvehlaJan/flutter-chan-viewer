import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';

import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc();

  Future<void> initBloc() async {
    await getIt.getAsync<Preferences>();
    await getIt.getAsync<ChanDownloader>();
    await getIt.getAsync<ChanStorage>();
    await getIt.getAsync<ChanRepository>();
  }

  @override
  get initialState => AppStateLoading();

  @override
  Stream<AppState> mapEventToState(AppEvent event) async* {
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
    } catch (e, stackTrace) {
      ChanLogger.e("Event error!", e, stackTrace);
      yield AppStateError(e.toString());
    }
  }
}
