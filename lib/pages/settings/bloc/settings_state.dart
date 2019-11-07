import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';

abstract class SettingsState extends Equatable {
  SettingsState([List props = const []]) : super(props);
}

class SettingsStateLoading extends SettingsState {
  @override
  String toString() => 'SettingsStateLoading';
}

class SettingsStateError extends SettingsState {
  final String message;

  SettingsStateError(this.message);

  @override
  String toString() => 'SettingsStateError { message: $message }';
}

class SettingsStateContent extends SettingsState {
  final AppTheme theme;

  SettingsStateContent(this.theme) : super([theme]);

  @override
  String toString() => 'SettingsStateContent { theme: $theme }';
}
