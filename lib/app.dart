import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_viewer_bloc/chan_viewer_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_viewer_bloc/chan_viewer_state.dart';
import 'package:flutter_chan_viewer/pages/board_list/bloc/board_list_bloc.dart';
import 'package:flutter_chan_viewer/pages/board_list/board_list_page.dart';
import 'package:flutter_chan_viewer/pages/favorites/bloc/favorites_bloc.dart';
import 'package:flutter_chan_viewer/pages/favorites/favorites_page.dart';
import 'package:flutter_chan_viewer/pages/settings/bloc/settings_bloc.dart';
import 'package:flutter_chan_viewer/pages/settings/settings_page.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';

import 'navigation/navigation_helper.dart';
import 'navigation/tab_navigator.dart';

class ChanViewerApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChanViewerAppState();
}

class ChanViewerAppState extends State<ChanViewerApp> {
  /*
    changed currentTab to static to show the last shown navigator
    if it is not static it shows always the red Navigator if you pop from inputPage and not the last opened one
  */
  static Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    /*
      changed navigatorKeys to static to prevent generating new keys on every reuse of the App widget
      if new keys will generated new navigators will be used and because of this the state of each tab will be deleted
    */
    TabItem.favs: GlobalKey<NavigatorState>(),
    TabItem.boards: GlobalKey<NavigatorState>(),
    TabItem.settings: GlobalKey<NavigatorState>(),
  };

  static TabItem currentTab = TabItem.boards;

  void _selectTabIndex(int tabIndex) {
    setState(() {
      currentTab = NavigationHelper.item(index: tabIndex);
    });
  }

  final List<Widget> _children = [
    BlocProvider(create: (context) => FavoritesBloc(), child: FavoritesPage()),
    BlocProvider(create: (context) => BoardListBloc(), child: BoardListPage()),
    BlocProvider(create: (context) => SettingsBloc(), child: SettingsPage())
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChanViewerBloc, ChanViewerState>(builder: (context, state) {
      if (state is ChanViewerStateContent) {
        return Scaffold(
          body: _children[currentTab.index],
          bottomNavigationBar: state.showBottomBar
              ? BottomNavigationBar(
                  showUnselectedLabels: false,
                  showSelectedLabels: false,
                  backgroundColor: Theme.of(context).primaryColor,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.white54,
                  items: NavigationHelper.getItems(context),
                  currentIndex: currentTab.index,
                  onTap: _selectTabIndex,
                )
              : null,
        );
      } else {
        return Constants.errorPlaceholder;
      }
    });
  }

//  @override
//  Widget build(BuildContext context) {
//    return BlocBuilder<ChanViewerBloc, ChanViewerState>(builder: (context, state) {
//      if (state is ChanViewerStateContent) {
//        return WillPopScope(
//          onWillPop: () async => !await navigatorKeys[currentTab].currentState.maybePop(),
//          child: Scaffold(
//            body: Stack(children: <Widget>[
//              _buildOffstageNavigator(TabItem.favs),
//              _buildOffstageNavigator(TabItem.boards),
//              _buildOffstageNavigator(TabItem.settings),
//            ]),
//            bottomNavigationBar: state.showBottomBar
//                ? BottomNavigationBar(
//                    showUnselectedLabels: false,
//                    showSelectedLabels: false,
//                    backgroundColor: Theme.of(context).primaryColor,
//                    selectedItemColor: Colors.white,
//                    unselectedItemColor: Colors.white54,
//                    items: TabHelper.getItems(context),
//                    currentIndex: currentTab.index,
//                    onTap: _selectTabIndex,
//                  )
//                : null,
//          ),
//        );
//      } else {
//        return Constants.errorPlaceholder;
//      }
//    });
//  }

  Widget _buildOffstageNavigator(TabItem tabItem) {
    return Offstage(
      offstage: currentTab != tabItem,
      child: TabNavigator(
        navigatorKey: navigatorKeys[tabItem],
        tabItem: tabItem,
        rootContext: context,
        /*
          this context is the context to the root navigator of MaterialApp
          the context is passed to each navigator and then to each page to give every page access to the root navigator
         */
      ),
    );
  }
}
