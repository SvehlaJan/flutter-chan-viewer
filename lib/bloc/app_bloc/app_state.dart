import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';

abstract class AppState extends Equatable {
  AppState([List props = const []]) : super(props);
}

class AppStateLoading extends AppState {
  @override
  String toString() => 'AppStateLoading';
}

class AppStateError extends AppState {
  final String message;

  AppStateError(this.message);

  @override
  String toString() => 'AppStateError { message: $message }';
}

class AppStateContent extends AppState {
  final AppTheme appTheme;

  AppStateContent(this.appTheme)
      : super([
          appTheme,
        ]);

  @override
  String toString() => 'AppStateContent { appTheme: $appTheme }';
}
