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

class SettingsEventToggleShowNsfw extends ChanEvent {
  final bool enabled;

  SettingsEventToggleShowNsfw(this.enabled);

  @override
  List<Object> get props => [enabled];
}

class SettingsEventToggleBiometricLock extends ChanEvent {
  final bool enabled;

  SettingsEventToggleBiometricLock(this.enabled);
  
  @override
  List<Object> get props => [enabled];
}

class SettingsEventCancelDownloads extends ChanEvent {}

class SettingsEventPurgeDatabase extends ChanEvent {}

class SettingsEventDeleteFolder extends ChanEvent {
  final CacheDirective cacheDirective;

  SettingsEventDeleteFolder(this.cacheDirective);

  @override
  List<Object> get props => [cacheDirective];
}
