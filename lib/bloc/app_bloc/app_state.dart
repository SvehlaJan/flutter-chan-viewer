import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';

class AppStateContent extends ChanState {
  final AppTheme appTheme;

  AppStateContent(this.appTheme);

  @override
  List<Object> get props => [appTheme];
}
