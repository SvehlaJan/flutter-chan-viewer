import 'dart:async';
import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/models/board_list_model.dart';
import 'package:flutter_chan_viewer/models/board_detail_model.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final _repository = ChanRepository.get();
  AppTheme _appTheme;

  @override
  get initialState => SettingsStateLoading();

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    print("Event received! ${event.toString()}");
    print("Current state! ${state.toString()}");
    try {
      if (event is SettingsEventSetTheme) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt(Preferences.KEY_SETTINGS_THEME, event.theme.index);
        _appTheme = event.theme;

        yield SettingsStateContent(_appTheme);
      } else if (event is SettingsEventFetchData) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int appThemeIndex = prefs.getInt(Preferences.KEY_SETTINGS_THEME) ?? 0;
        _appTheme = AppTheme.values[appThemeIndex];

        yield SettingsStateContent(_appTheme);
      } else if (event is SettingsEventExperiment) {
        yield SettingsStateLoading();
        HashMap<String, List<String>> threadMap = await _repository.getFavoriteThreadNames();

        yield SettingsStateContent(_appTheme);
      }
    } catch (e) {
      print("Event error! ${e.toString()}");
      yield SettingsStateError(e.toString());
    }
  }
}
