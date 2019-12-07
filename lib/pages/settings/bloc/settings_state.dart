import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';

abstract class SettingsState extends Equatable {
  SettingsState();
}

class SettingsStateLoading extends SettingsState {
  @override
  String toString() => 'SettingsStateLoading';

  @override
  List<Object> get props => [];
}

class SettingsStateError extends SettingsState {
  final String message;

  SettingsStateError(this.message);

  @override
  String toString() => 'SettingsStateError { message: $message }';

  @override
  List<Object> get props => [message];
}

class SettingsStateContent extends SettingsState {
  final AppTheme theme;

  SettingsStateContent(this.theme);

  @override
  String toString() => 'SettingsStateContent { theme: $theme }';

  @override
  List<Object> get props => [theme];
}
