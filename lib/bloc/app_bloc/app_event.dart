import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => [];
}

class AppEventAppStarted extends AppEvent {}

class AppEventSetTheme extends AppEvent {
  final AppTheme appTheme;

  AppEventSetTheme(this.appTheme);

  @override
  List<Object?> get props => super.props..addAll([appTheme]);
}

class AppEventLifecycleChange extends AppEvent {
  final AppLifecycleState lastLifecycleState;

  const AppEventLifecycleChange({required this.lastLifecycleState});

  @override
  List<Object?> get props => super.props..addAll([lastLifecycleState]);
}
