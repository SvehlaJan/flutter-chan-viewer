import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/app_bloc/app_bloc.dart';
import 'package:flutter_chan_viewer/pages/board_list/bloc/board_list_bloc.dart';
import 'package:flutter_chan_viewer/pages/board_list/board_list_page.dart';
import 'package:flutter_chan_viewer/pages/favorites/bloc/favorites_bloc.dart';
import 'package:flutter_chan_viewer/pages/favorites/favorites_page.dart';
import 'package:flutter_chan_viewer/pages/settings/bloc/settings_bloc.dart';
import 'package:flutter_chan_viewer/pages/settings/settings_page.dart';

import 'bloc/app_bloc/app_event.dart';
import 'utils/navigation_helper.dart';

class BottomNavigationApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BottomNavigationAppState();
}

class BottomNavigationAppState extends State<BottomNavigationApp> with WidgetsBindingObserver {
  TabItem _selectedTab = TabItem.boards;

  final List<Widget> _children = [
    BlocProvider(create: (context) => FavoritesBloc(), child: FavoritesPage()),
    BlocProvider(create: (context) => BoardListBloc(), child: BoardListPage()),
    BlocProvider(create: (context) => SettingsBloc(), child: SettingsPage())
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    AppBloc appBloc = BlocProvider.of<AppBloc>(context);
    appBloc.add(AppEventLifecycleChange(lastLifecycleState: state));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_selectedTab.index],
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: false,
        showSelectedLabels: false,
        items: NavigationHelper.getItems(context),
        currentIndex: _selectedTab.index,
        onTap: (tabIndex) {
          setState(() {
            _selectedTab = NavigationHelper.item(tabIndex);
          });
        },
      ),
    );
  }
}
