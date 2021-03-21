import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

import 'utils/navigation_helper.dart';

class ChanViewerApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChanViewerAppState();
}

class ChanViewerAppState extends State<ChanViewerApp> {
  static TabItem currentTab = TabItem.boards;

  void _selectTabIndex(int tabIndex) {
    setState(() {
      currentTab = NavigationHelper.item(tabIndex);
    });
  }

  final List<Widget> _children = [
    BlocProvider(create: (context) => FavoritesBloc(), child: FavoritesPage()),
    BlocProvider(create: (context) => BoardListBloc(), child: BoardListPage()),
    BlocProvider(create: (context) => SettingsBloc(), child: SettingsPage())
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChanViewerBloc, ChanState>(builder: (context, state) {
      if (state is ChanViewerStateContent) {
        return Scaffold(
          body: _children[currentTab.index],
          bottomNavigationBar: BottomNavigationBar(
            showUnselectedLabels: false,
            showSelectedLabels: false,
            items: NavigationHelper.getItems(context),
            currentIndex: currentTab.index,
            onTap: (tabIndex) => _selectTabIndex(tabIndex),
          ),
        );
      } else {
        return BasePageState.buildErrorScreen(context, (state as ChanStateError).message);
      }
    });
  }
}
