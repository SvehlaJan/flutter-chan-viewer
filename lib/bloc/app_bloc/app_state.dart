import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/navigation_helper.dart';

class AppStateContent extends ChanState {
  final AppTheme appTheme;
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
