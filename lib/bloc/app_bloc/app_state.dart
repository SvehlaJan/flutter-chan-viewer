import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan_viewer/utils/navigation_helper.dart';

@immutable
sealed class AppState extends Equatable {
  final AppSingleEvent? event;

  AppState({
    required this.event,
  });

  @override
  List<Object?> get props => [event];
}

class AppStateError extends AppState {
  final String message;

  AppStateError(
      this.message, {
        AppSingleEvent? event,
      }) : super(event: event);

  @override
  List<Object?> get props => super.props..addAll([message]);
}

@immutable
class AppStateLoading extends AppState {
  AppStateLoading({
    AppSingleEvent? event,
  }) : super(event: event);
}

class AppStateContent extends AppState {
  final ThemeData appTheme;
  final AuthState authState;

  AppStateContent({
    required this.appTheme,
    required this.authState,
    event,
  }) : super(event: event);

  @override
  List<Object?> get props => super.props..addAll([appTheme, authState]);
}

@immutable
sealed class AppSingleEvent extends Equatable {}
