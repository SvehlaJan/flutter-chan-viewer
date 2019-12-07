import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';

abstract class AppState extends Equatable {
  AppState();
}

class AppStateLoading extends AppState {
  @override
  String toString() => 'AppStateLoading';

  @override
  List<Object> get props => [];
}

class AppStateError extends AppState {
  final String message;

  AppStateError(this.message);

  @override
  String toString() => 'AppStateError { message: $message }';

  @override
  List<Object> get props => [message];
}

class AppStateContent extends AppState {
  final AppTheme appTheme;

  AppStateContent(this.appTheme);

  @override
  String toString() => 'AppStateContent { appTheme: $appTheme }';

  @override
  List<Object> get props => [appTheme];
}
