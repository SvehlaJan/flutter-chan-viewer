import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/app_bloc/app_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/bloc/chan_viewer_bloc/chan_viewer_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_viewer_bloc/chan_viewer_state.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/board_list/bloc/board_list_bloc.dart';
import 'package:flutter_chan_viewer/pages/board_list/board_list_page.dart';
import 'package:flutter_chan_viewer/pages/favorites/bloc/favorites_bloc.dart';
import 'package:flutter_chan_viewer/pages/favorites/favorites_page.dart';
import 'package:flutter_chan_viewer/pages/settings/bloc/settings_bloc.dart';
import 'package:flutter_chan_viewer/pages/settings/settings_page.dart';

import 'bloc/app_bloc/app_event.dart';
import 'bloc/chan_viewer_bloc/chan_viewer_event.dart';
import 'utils/navigation_helper.dart';

class ChanViewerApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChanViewerAppState();
}

class ChanViewerAppState extends State<ChanViewerApp> with WidgetsBindingObserver {
  late Bloc bloc;
  final List<Widget> _children = [
    BlocProvider(create: (context) => FavoritesBloc(), child: FavoritesPage()),
    BlocProvider(create: (context) => BoardListBloc(), child: BoardListPage()),
    BlocProvider(create: (context) => SettingsBloc(), child: SettingsPage())
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    bloc = BlocProvider.of<ChanViewerBloc>(context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("didChangeAppLifecycleState: $state");
    AppBloc appBloc = BlocProvider.of<AppBloc>(context);
    appBloc.add(AppEventLifecycleChange(lastLifecycleState: state));
  }

  void _selectTabIndex(int tabIndex) {
    bloc.add(ChanViewerEventSelectTab(selectedTab: NavigationHelper.item(tabIndex)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChanViewerBloc, ChanState>(
      builder: (context, state) {
        if (state is ChanViewerStateContent) {
          return Scaffold(
            body: _children[state.currentTab.index],
            bottomNavigationBar: BottomNavigationBar(
              showUnselectedLabels: false,
              showSelectedLabels: false,
              items: NavigationHelper.getItems(context),
              currentIndex: state.currentTab.index,
              onTap: (tabIndex) => _selectTabIndex(tabIndex),
            ),
          );
        } else {
          return BasePageState.buildErrorScreen(context, (state as ChanStateError).message);
        }
      },
      bloc: bloc as ChanViewerBloc,
    );
  }
}
