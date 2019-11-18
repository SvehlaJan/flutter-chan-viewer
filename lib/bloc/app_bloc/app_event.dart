import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';

abstract class AppEvent extends Equatable {
  AppEvent([List props = const []]) : super(props);
}

class AppEventAppStarted extends AppEvent {
  @override
  String toString() => 'AppEventAppStarted { }';
}

class AppEventSetTheme extends AppEvent {
  final AppTheme appTheme;

  AppEventSetTheme(this.appTheme);

  @override
  String toString() => 'AppEventShowBottomBar { appTheme: $appTheme }';
}