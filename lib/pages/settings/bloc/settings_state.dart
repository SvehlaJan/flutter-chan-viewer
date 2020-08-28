import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/helper/moor_db_overview.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';

class SettingsStateContent extends ChanState {
  final AppTheme theme;
  final List<DownloadFolderInfo> downloads;
  final bool showNsfw;
  final MoorDbOverview moorDbOverview;

  SettingsStateContent(this.theme, this.downloads, this.showNsfw, this.moorDbOverview);

  @override
  List<Object> get props => [theme, downloads, showNsfw];
}
