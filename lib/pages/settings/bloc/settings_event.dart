import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';

abstract class SettingsEvent extends Equatable {
  SettingsEvent();
}

class SettingsEventFetchData extends SettingsEvent {
  SettingsEventFetchData();

  @override
  String toString() => 'SettingsEventFetchData { }';

  @override
  List<Object> get props => [];
}

class SettingsEventSetTheme extends SettingsEvent {
  final AppTheme theme;

  SettingsEventSetTheme(this.theme);

  @override
  String toString() => 'SettingsEventSetTheme { theme: $theme }';

  @override
  List<Object> get props => [theme];
}

class SettingsEventExperiment extends SettingsEvent {
  SettingsEventExperiment();

  @override
  String toString() => 'SettingsEventExperiment { }';

  @override
  List<Object> get props => [];
}