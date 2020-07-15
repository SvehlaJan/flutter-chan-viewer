import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';

class SettingsEventSetTheme extends ChanEvent {
  final AppTheme theme;

  SettingsEventSetTheme(this.theme);

  @override
  String toString() => 'SettingsEventSetTheme {theme: $theme}';

  @override
  List<Object> get props => [theme];
}

class SettingsEventExperiment extends ChanEvent {}

class SettingsEventToggleShowSfwOnly extends ChanEvent {
  final bool showNsfw;

  SettingsEventToggleShowSfwOnly(this.showNsfw);

  @override
  List<Object> get props => [showNsfw];
}

class SettingsEventCancelDownloads extends ChanEvent {}

class SettingsEventDeleteFolder extends ChanEvent {
  final CacheDirective cacheDirective;

  SettingsEventDeleteFolder(this.cacheDirective);

  @override
  List<Object> get props => [cacheDirective];
}