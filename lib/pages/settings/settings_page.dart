import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/app_bloc/app_bloc.dart';
import 'package:flutter_chan_viewer/bloc/app_bloc/app_event.dart';
import 'package:flutter_chan_viewer/navigation/navigation_helper.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/settings/bloc/settings_bloc.dart';
import 'package:flutter_chan_viewer/pages/settings/bloc/settings_event.dart';
import 'package:flutter_chan_viewer/pages/settings/bloc/settings_state.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/thread_detail_page.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/view/view_common_switch.dart';

class SettingsPage extends BasePage {
  SettingsPage();

  @override
  State<StatefulWidget> createState() => new _SettingsPageState();
}

class _SettingsPageState extends BasePageState<SettingsPage> {
  SettingsBloc _settingsBloc;

  @override
  void initState() {
    super.initState();
    _settingsBloc = BlocProvider.of<SettingsBloc>(context);
    _settingsBloc.add(SettingsEventFetchData());
  }

  @override
  String getPageTitle() => "Settings";

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(bloc: _settingsBloc, builder: (context, state) => buildPage(context, buildBody(context, state)));
  }

  Widget buildBody(BuildContext context, SettingsState state) {
    if (state is SettingsStateLoading) {
      return Constants.centeredProgressIndicator;
    } else if (state is SettingsStateContent) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Visual", style: Theme.of(context).textTheme.subhead),
            ),
            Card(
              color: Colors.white,
              elevation: 2.0,
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(
                      Icons.format_paint,
                      color: Colors.grey,
                    ),
                    title: Text("Dark theme"),
                    trailing: CommonSwitch(
                      onChanged: _onThemeSwitchClicked,
                      defValue: (state.theme == AppTheme.dark) ? true : false,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Others", style: Theme.of(context).textTheme.subhead),
            ),
            Card(
              color: Colors.white,
              elevation: 2.0,
              child: Column(
                children: <Widget>[
                  ListTile(leading: Icon(Icons.block, color: Colors.red), title: Text("Experiment"), onTap: _onExperimentClicked),
                  ListTile(
                    leading: Icon(
                      Icons.priority_high,
                      color: Colors.grey,
                    ),
                    title: Text("Show SFW Only"),
                    trailing: CommonSwitch(
                      onChanged: _onToggleShowSfwOnlyClicked,
                      defValue: state.showSfwOnly,
                    ),
                  ),
                  ListTile(leading: Icon(Icons.cancel, color: Colors.red), title: Text("Cancel downloads"), onTap: _onCancelDownloadsClicked),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Downloads", style: Theme.of(context).textTheme.subhead),
            ),
            ListView.builder(
              itemCount: state.downloads.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                DownloadFolderInfo folderInfo = state.downloads[index];
                return Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: ListTile(
                    title: Text(folderInfo.cacheDirective.toPath()),
                    subtitle: Text("Size: ${filesize(folderInfo.filesSize)} Files ${folderInfo.filesCount}"),
                    trailing: IconButton(icon: Icon(Icons.delete), onPressed: () => _onDeleteFolderClicked(folderInfo.cacheDirective)),
                    onTap: () => _onFolderTileClicked(folderInfo),
                  ),
                );
              },
            ),
          ],
        ),
      );
    } else {
      return Constants.errorPlaceholder;
    }
  }

  void _onFolderTileClicked(DownloadFolderInfo folderInfo) {
    Navigator.of(context).push(
      NavigationHelper.getRoute(
        Constants.threadDetailRoute,
        ThreadDetailPage.getArguments(folderInfo.cacheDirective.boardId, folderInfo.cacheDirective.threadId, true),
      ),
    );
//    Navigator.pushNamed(
//      context,
//      Constants.threadDetailRoute,
//      arguments: ThreadDetailPage.getArguments(folderInfo.cacheDirective.boardId, folderInfo.cacheDirective.threadId, true),
//    );
  }

  void _onThemeSwitchClicked(bool enabled) {
    AppTheme newTheme = enabled ? AppTheme.dark : AppTheme.light;
    _settingsBloc.add(SettingsEventSetTheme(newTheme));
    BlocProvider.of<AppBloc>(context).add(AppEventSetTheme(newTheme));
  }

  void _onExperimentClicked() => _settingsBloc.add(SettingsEventExperiment());

  void _onToggleShowSfwOnlyClicked(bool enabled) => _settingsBloc.add(SettingsEventToggleShowSfwOnly(enabled));

  void _onCancelDownloadsClicked() => _settingsBloc.add(SettingsEventCancelDownloads());

  void _onDeleteFolderClicked(CacheDirective cacheDirective) => _settingsBloc.add(SettingsEventDeleteFolder(cacheDirective));
}
