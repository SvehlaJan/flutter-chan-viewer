import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';

class SettingsStateContent extends ChanState {
  final AppTheme theme;
  final List<DownloadFolderInfo> downloads;
  final bool showNsfw;

  SettingsStateContent(this.theme, this.downloads, this.showNsfw);

  @override
  List<Object> get props => [theme, downloads, showNsfw];
}
