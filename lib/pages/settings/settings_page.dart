import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/app_bloc/app_bloc.dart';
import 'package:flutter_chan_viewer/bloc/app_bloc/app_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/helper/moor_db_overview.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/board_detail/board_detail_page.dart';
import 'package:flutter_chan_viewer/pages/settings/bloc/settings_bloc.dart';
import 'package:flutter_chan_viewer/pages/settings/bloc/settings_event.dart';
import 'package:flutter_chan_viewer/pages/settings/bloc/settings_state.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/thread_detail_page.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/navigation_helper.dart';
import 'package:flutter_chan_viewer/view/view_common_switch.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends BasePageState<SettingsPage> {
  late SettingsBloc _settingsBloc;

  @override
  void initState() {
    super.initState();
    _settingsBloc = BlocProvider.of<SettingsBloc>(context);
    _settingsBloc.add(ChanEventFetchData());
  }

  @override
  String getPageTitle() => "Settings";

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, ChanState>(
      bloc: _settingsBloc,
      builder: (context, state) => buildScaffold(context, buildBody(context, state)),
    );
  }

  Widget buildBody(BuildContext context, ChanState state) {
    if (state is ChanStateLoading) {
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
              elevation: 2.0,
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(
                      Icons.format_paint,
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
              elevation: 2.0,
              child: Column(
                children: <Widget>[
                  ListTile(leading: Icon(Icons.block), title: Text("Experiment"), onTap: _onExperimentClicked),
                  ListTile(
                    leading: Icon(Icons.priority_high),
                    title: Text("Show NSFW"),
                    trailing: CommonSwitch(onChanged: _onToggleShowSfwOnlyClicked, defValue: state.showNsfw),
                  ),
                  ListTile(leading: Icon(Icons.cancel), title: Text("Cancel downloads"), onTap: _onCancelDownloadsClicked),
                ],
              ),
            ),
            if (state.moorDbOverview.boards.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Db overview", style: Theme.of(context).textTheme.subhead),
              ),
            if (state.moorDbOverview.boards.isNotEmpty)
              ListView.builder(
                itemCount: state.moorDbOverview.boards.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  MoorBoardOverview boardOverview = state.moorDbOverview.boards[index];
                  return Card(
                    elevation: 2.0,
                    child: ListTile(
                      title: Text(boardOverview.boardId!),
                      subtitle: Text(
                          "Online: ${boardOverview.onlineCount}\nArchived: ${boardOverview.archivedCount}\nNot found: ${boardOverview.notFoundCount}\nUnknown: ${boardOverview.unknownCount}"),
                      onTap: () => _onMoorBoardOverviewClicked(boardOverview),
                    ),
                  );
                },
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Downloads", style: Theme.of(context).textTheme.subhead),
            ),
            ListView.builder(
              itemCount: state.downloads!.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                DownloadFolderInfo folderInfo = state.downloads![index];
                return Card(
                  elevation: 2.0,
                  child: ListTile(
                    title: Text(folderInfo.cacheDirective.toPath()),
                    subtitle: Text("Size: ${folderInfo.filesSize} Files ${folderInfo.filesCount}"),
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
      return BasePageState.buildErrorScreen(context, (state as ChanStateError).message);
    }
  }

  void _onFolderTileClicked(DownloadFolderInfo folderInfo) {
    Navigator.of(context).push(
      NavigationHelper.getRoute(
        Constants.threadDetailRoute,
        ThreadDetailPage.createArguments(folderInfo.cacheDirective.boardId, folderInfo.cacheDirective.threadId, showDownloadsOnly: true),
      )!,
    );
  }

  void _onMoorBoardOverviewClicked(MoorBoardOverview boardOverview) {
    Navigator.of(context).push(
      NavigationHelper.getRoute(
        Constants.boardDetailRoute,
        BoardDetailPage.createArguments(boardOverview.boardId),
      )!,
    );
  }

  void _onThemeSwitchClicked(bool enabled) {
    AppTheme newTheme = enabled ? AppTheme.dark : AppTheme.light;
    _settingsBloc.add(SettingsEventSetTheme(newTheme));
    BlocProvider.of<AppBloc>(context).add(AppEventSetTheme(newTheme));
  }

  void _onExperimentClicked() => _settingsBloc.add(SettingsEventExperiment());

  void _onToggleShowSfwOnlyClicked(bool enabled) => _settingsBloc.add(SettingsEventToggleShowNsfw(enabled));

  void _onCancelDownloadsClicked() => _settingsBloc.add(SettingsEventCancelDownloads());

  void _onDeleteFolderClicked(CacheDirective cacheDirective) => _settingsBloc.add(SettingsEventDeleteFolder(cacheDirective));
}
