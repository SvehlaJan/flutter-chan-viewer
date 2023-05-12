import 'package:flutter/material.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/utils/navigation_helper.dart';

class AppStateContent extends ChanState {
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

class AppStateLoading extends ChanState {}
