import 'package:flutter/material.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';

enum TabItem { favs, boards, settings }

class TabHelper {
  static List<BottomNavigationBarItem> getItems(BuildContext context) {
    List<BottomNavigationBarItem> items = <BottomNavigationBarItem>[];
    for (TabItem tabItem in TabItem.values) {
      items.add(BottomNavigationBarItem(
          icon: Icon(getIcon(tabItem)),
          title: Text(getDescription(tabItem), style: Theme.of(context).textTheme.body1,)));
    }
    return items;
  }

  static TabItem item({int index}) {
    switch (index) {
      case 0:
        return TabItem.favs;
      case 1:
        return TabItem.boards;
      case 2:
        return TabItem.settings;
    }
    return TabItem.boards;
  }

  static String getDescription(TabItem tabItem) {
    switch (tabItem) {
      case TabItem.favs:
        return 'FAVS';
      case TabItem.boards:
        return 'BOARDS';
      case TabItem.settings:
        return 'SETTINGS';
    }
    return '';
  }

  static String getInitialRoute(TabItem tabItem) {
    switch (tabItem) {
      case TabItem.favs:
        return Constants.favoritesRoute;
      case TabItem.boards:
        return Constants.boardsRoute;
      case TabItem.settings:
        return Constants.settingsRoute;
    }
    return Constants.notFoundRoute;
  }

  static IconData getIcon(TabItem tabItem) {
    switch (tabItem) {
      case TabItem.favs:
        return Icons.star;
      case TabItem.boards:
        return Icons.dashboard;
      case TabItem.settings:
        return Icons.settings;
    }
    return Icons.error;
  }

  static MaterialColor getColor(TabItem tabItem, BuildContext context) {
    switch (tabItem) {
      case TabItem.favs:
        return Theme.of(context).accentColor;
      case TabItem.boards:
        return Theme.of(context).accentColor;
      case TabItem.settings:
        return Theme.of(context).accentColor;
    }
    return Colors.grey;
  }
}
