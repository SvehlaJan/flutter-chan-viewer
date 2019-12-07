import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';

abstract class AppEvent extends Equatable {
  AppEvent();
}

class AppEventAppStarted extends AppEvent {
  @override
  String toString() => 'AppEventAppStarted { }';

  @override
  List<Object> get props => [];
}

class AppEventSetTheme extends AppEvent {
  final AppTheme appTheme;

  AppEventSetTheme(this.appTheme);

  @override
  String toString() => 'AppEventShowBottomBar { appTheme: $appTheme }';

  @override
  List<Object> get props => [appTheme];
}
