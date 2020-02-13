import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';

abstract class SettingsEvent extends Equatable {
  SettingsEvent();

  @override
  List<Object> get props => [];
}

class SettingsEventFetchData extends SettingsEvent {}

class SettingsEventSetTheme extends SettingsEvent {
  final AppTheme theme;

  SettingsEventSetTheme(this.theme);

  @override
  String toString() => 'SettingsEventSetTheme {theme: $theme}';

  @override
  List<Object> get props => [theme];
}

class SettingsEventExperiment extends SettingsEvent {}

class SettingsEventToggleNSFW extends SettingsEvent {
  final bool enabled;

  SettingsEventToggleNSFW(this.enabled);

  @override
  List<Object> get props => [enabled];
}

class SettingsEventCancelDownloads extends SettingsEvent {}

class SettingsEventDeleteFolder extends SettingsEvent {
  final CacheDirective cacheDirective;

  SettingsEventDeleteFolder(this.cacheDirective);

  @override
  List<Object> get props => [cacheDirective];
}