import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/pages/base/notfound_page.dart';
import 'package:flutter_chan_viewer/pages/board_archive/bloc/board_archive_bloc.dart';
import 'package:flutter_chan_viewer/pages/board_archive/board_archive_page.dart';
import 'package:flutter_chan_viewer/pages/board_detail/bloc/board_detail_bloc.dart';
import 'package:flutter_chan_viewer/pages/board_detail/board_detail_page.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/bloc/thread_detail_bloc.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/thread_detail_page.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';

enum TabItem { favorites, boards, settings }

class NavigationHelper {
  static List<BottomNavigationBarItem> getItems(BuildContext context) {
    List<BottomNavigationBarItem> items = <BottomNavigationBarItem>[];
    for (TabItem tabItem in TabItem.values) {
      items.add(BottomNavigationBarItem(
        icon: Icon(getIcon(tabItem)),
        title: Text(getDescription(tabItem), style: Theme.of(context).textTheme.body1),
      ));
    }
    return items;
  }

  static TabItem item(int index) {
    switch (index) {
      case 0:
        return TabItem.favorites;
      case 1:
        return TabItem.boards;
      case 2:
        return TabItem.settings;
    }
    return TabItem.boards;
  }

  static String getDescription(TabItem tabItem) {
    switch (tabItem) {
      case TabItem.favorites:
        return 'FAVS';
      case TabItem.boards:
        return 'BOARDS';
      case TabItem.settings:
        return 'SETTINGS';
    }
    return '';
  }

  static IconData getIcon(TabItem tabItem) {
    switch (tabItem) {
      case TabItem.favorites:
        return Icons.star;
      case TabItem.boards:
        return Icons.dashboard;
      case TabItem.settings:
        return Icons.settings;
    }
    return Icons.error;
  }

  static Route<dynamic> getRoute(String name, Map<String, dynamic> arguments) {
    switch (name) {
      case Constants.boardDetailRoute:
        if (arguments != null && arguments.containsKey(BoardDetailPage.ARG_BOARD_ID)) {
          String boardId = arguments[BoardDetailPage.ARG_BOARD_ID];
          return MaterialPageRoute<void>(
            builder: (BuildContext context) => BlocProvider(
              create: (context) => BoardDetailBloc(boardId),
              child: BoardDetailPage(boardId),
            ),
          );
        }
        return null;
      case Constants.boardArchiveRoute:
        if (arguments != null && arguments.containsKey(BoardArchivePage.ARG_BOARD_ID)) {
          String boardId = arguments[BoardArchivePage.ARG_BOARD_ID];
          return MaterialPageRoute<void>(
            builder: (BuildContext context) => BlocProvider(
              create: (context) => BoardArchiveBloc(boardId),
              child: BoardArchivePage(boardId),
            ),
          );
        }
        return null;
      case Constants.threadDetailRoute:
        if (arguments != null && arguments.containsKey(ThreadDetailPage.ARG_BOARD_ID) && arguments.containsKey(ThreadDetailPage.ARG_THREAD_ID)) {
          return MaterialPageRoute<void>(
            builder: (BuildContext context) => BlocProvider(
              create: (context) => ThreadDetailBloc(
                arguments[ThreadDetailPage.ARG_BOARD_ID],
                arguments[ThreadDetailPage.ARG_THREAD_ID],
                arguments[ThreadDetailPage.ARG_SHOW_APP_BAR],
                arguments[ThreadDetailPage.ARG_SHOW_DOWNLOADS_ONLY],
                arguments[ThreadDetailPage.ARG_CATALOG_MODE],
              ),
              child: ThreadDetailPage(),
            ),
          );
        }
        return null;
    }

    // The other paths we support are in the routes table.
    return MaterialPageRoute(builder: (context) => NotFoundPage());
  }
}
