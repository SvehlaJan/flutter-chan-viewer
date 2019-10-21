import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/app_bloc/app_bloc.dart';
import 'package:flutter_chan_viewer/bloc/app_bloc/app_event.dart';
import 'package:flutter_chan_viewer/bloc/app_bloc/app_state.dart';

import 'navigation/tab_helper.dart';
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
  AppBloc _appBloc;

  @override
  void initState() {
    super.initState();
    _appBloc = BlocProvider.of<AppBloc>(context);
    _appBloc.dispatch(AppEventShowBottomBar(true));
  }

  void _selectTabIndex(int tabIndex) {
    setState(() {
      currentTab = TabHelper.item(index: tabIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(builder: (context, state) {
      print("App bloc state: $state");

      if (state is AppStateLoading) {
        return Center(child: CircularProgressIndicator());
      } else if (state is AppStateContent) {
        return WillPopScope(
          onWillPop: () async => !await navigatorKeys[currentTab].currentState.maybePop(),
          child: Scaffold(
            body: Stack(children: <Widget>[
              _buildOffstageNavigator(TabItem.favs),
              _buildOffstageNavigator(TabItem.boards),
              _buildOffstageNavigator(TabItem.settings),
            ]),
            bottomNavigationBar: state.showBottomBar ? BottomNavigationBar(
              showUnselectedLabels: false,
              showSelectedLabels: false,
              backgroundColor: Theme.of(context).primaryColor,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white54,
              items: TabHelper.getItems(context),
              currentIndex: currentTab.index,
              onTap: _selectTabIndex,
            ) : null,
          ),
        );
      } else {
        return Center(child: Text('Error'));
      }
    });
  }

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
