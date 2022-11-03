import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/navigation_helper.dart';

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

class AppEventAuthStateChange extends AppEvent {
  final AuthState authState;

  const AppEventAuthStateChange({required this.authState});

  @override
  List<Object?> get props => super.props..addAll([authState]);
}

class AppEventPermissionRequestFinished extends AppEvent {
  final bool granted;

  const AppEventPermissionRequestFinished({required this.granted});

  @override
  List<Object?> get props => super.props..addAll([granted]);
}
