import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';

abstract class SettingsEvent extends Equatable {
  SettingsEvent([List props = const []]) : super(props);
}

class SettingsEventFetchData extends SettingsEvent {
  SettingsEventFetchData() : super([]);

  @override
  String toString() => 'SettingsEventFetchData { }';
}

class SettingsEventSetTheme extends SettingsEvent {
  final AppTheme theme;

  SettingsEventSetTheme(this.theme) : super([theme]);

  @override
  String toString() => 'SettingsEventSetTheme { theme: $theme }';
}
