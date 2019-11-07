import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/models/boards_model.dart';
import 'package:flutter_chan_viewer/models/thread_model.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final _repository = ChanRepository.get();

  @override
  get initialState => SettingsStateLoading();

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    print("Event received! ${event.toString()}");
    print("Current state! ${currentState.toString()}");
    try {
      if (event is SettingsEventSetTheme) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt(Preferences.KEY_SETTINGS_THEME, event.theme.index);

        yield SettingsStateContent(event.theme);
      } else if (event is SettingsEventFetchData) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int appThemeIndex = prefs.getInt(Preferences.KEY_SETTINGS_THEME) ?? 0;
        AppTheme theme = AppTheme.values[appThemeIndex];

        yield SettingsStateContent(theme);
      }
    } catch (e) {
      print("Event error! ${e.toString()}");
      yield SettingsStateError(e.toString());
    }
  }
}
