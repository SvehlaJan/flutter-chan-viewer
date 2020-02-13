import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final _downloader = ChanDownloader.getSync();
  final _chanStorage = ChanStorage.getSync();
  AppTheme _appTheme;
  List<DownloadFolderInfo> _downloads = new List();
  bool _nsfwEnabled;

  @override
  get initialState => SettingsStateLoading();

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    try {
      if (event is SettingsEventSetTheme) {
        Preferences.setInt(Preferences.KEY_SETTINGS_THEME, event.theme.index);
        _appTheme = event.theme;
        yield SettingsStateContent(_appTheme, _downloads, _nsfwEnabled);
      } else if (event is SettingsEventFetchData) {
        int appThemeIndex = Preferences.getInt(Preferences.KEY_SETTINGS_THEME) ?? 0;
        _appTheme = AppTheme.values[appThemeIndex];
        _downloads = _chanStorage.getAllDownloadFoldersInfo();
        _nsfwEnabled = Preferences.getBool(Preferences.KEY_SETTINGS_SHOW_NSFW);

        yield SettingsStateContent(_appTheme, _downloads, _nsfwEnabled);
      } else if (event is SettingsEventExperiment) {
        yield SettingsStateLoading();
        yield SettingsStateContent(_appTheme, _downloads, _nsfwEnabled);
      } else if (event is SettingsEventToggleNSFW) {
        yield SettingsStateLoading();
        _nsfwEnabled = event.enabled;
        Preferences.setBool(Preferences.KEY_SETTINGS_SHOW_NSFW, _nsfwEnabled);
        yield SettingsStateContent(_appTheme, _downloads, _nsfwEnabled);
      } else if (event is SettingsEventCancelDownloads) {
        yield SettingsStateLoading();
        _downloader.cancelAllDownloads();
        yield SettingsStateContent(_appTheme, _downloads, _nsfwEnabled);
      } else if (event is SettingsEventDeleteFolder) {
        yield SettingsStateLoading();
        _chanStorage.deleteCacheFolder(event.cacheDirective);
        _downloads = _chanStorage.getAllDownloadFoldersInfo();
        yield SettingsStateContent(_appTheme, _downloads, _nsfwEnabled);
      }
    } catch (e) {
      ChanLogger.e("Event error!", e);
      yield SettingsStateError(e.toString());
    }
  }
}
