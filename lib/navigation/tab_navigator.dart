import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/pages/base/notfound_page.dart';
import 'package:flutter_chan_viewer/pages/board_detail/bloc/board_detail_bloc.dart';
import 'package:flutter_chan_viewer/pages/board_detail/board_detail_page.dart';
import 'package:flutter_chan_viewer/pages/board_list/bloc/board_list_bloc.dart';
import 'package:flutter_chan_viewer/pages/board_list/board_list_page.dart';
import 'package:flutter_chan_viewer/pages/favorites/bloc/favorites_bloc.dart';
import 'package:flutter_chan_viewer/pages/favorites/favorites_page.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/bloc/thread_detail_bloc.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/thread_detail_page.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/pages/gallery/gallery_page.dart';

import 'tab_helper.dart';

class TabNavigator extends StatelessWidget {
  TabNavigator({this.navigatorKey, this.tabItem, this.rootContext});

  final GlobalKey<NavigatorState> navigatorKey;
  final TabItem tabItem;
  final BuildContext rootContext;

  Route<dynamic> _getRoute(RouteSettings settings) {
    Map<String, dynamic> arguments;
    if (settings.arguments is Map<String, dynamic>) {
      arguments = settings.arguments;
    }

    switch (settings.name) {
      case Constants.favoritesRoute:
        return MaterialPageRoute<void>(settings: settings, builder: (BuildContext context) => BlocProvider(builder: (context) => FavoritesBloc(), child: FavoritesPage()));
      case Constants.boardsRoute:
        return MaterialPageRoute<void>(settings: settings, builder: (BuildContext context) => BlocProvider(builder: (context) => BoardListBloc(false), child: BoardListPage()));
      case Constants.boardDetailRoute:
        if (arguments != null && arguments.containsKey(BoardDetailPage.ARG_BOARD_ID)) {
          String boardId = arguments[BoardDetailPage.ARG_BOARD_ID];
          return MaterialPageRoute<void>(
              settings: settings, builder: (BuildContext context) => BlocProvider(builder: (context) => BoardDetailBloc(), child: BoardDetailPage(boardId)));
        }
        return null;
      case Constants.threadDetailRoute:
        if (arguments != null && arguments.containsKey(ThreadDetailPage.ARG_BOARD_ID) && arguments.containsKey(ThreadDetailPage.ARG_THREAD_ID)) {
          String boardId = arguments[ThreadDetailPage.ARG_BOARD_ID];
          int threadId = arguments[ThreadDetailPage.ARG_THREAD_ID];
          return MaterialPageRoute<void>(
              settings: settings, builder: (BuildContext context) => BlocProvider(builder: (context) => ThreadDetailBloc(), child: ThreadDetailPage(boardId, threadId)));
        }
        return null;
      case Constants.galleryRoute:
        if (arguments != null &&
            arguments.containsKey(GalleryPage.ARG_BOARD_ID) &&
            arguments.containsKey(GalleryPage.ARG_THREAD_ID) &&
            arguments.containsKey(GalleryPage.ARG_POST_ID)) {
          String boardId = arguments[GalleryPage.ARG_BOARD_ID];
          int threadId = arguments[GalleryPage.ARG_THREAD_ID];
          int postId = arguments[GalleryPage.ARG_POST_ID];
          return MaterialPageRoute<void>(
              settings: settings, builder: (BuildContext context) => BlocProvider(builder: (context) => ThreadDetailBloc(), child: GalleryPage(boardId, threadId, postId)));
        }
        return null;
      case Constants.settingsRoute:
        return MaterialPageRoute<void>(settings: settings, builder: (BuildContext context) => NotFoundPage());
      case Constants.favoritesRoute:
        return MaterialPageRoute<void>(settings: settings, builder: (BuildContext context) => NotFoundPage());
    }

    // The other paths we support are in the routes table.
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: TabHelper.getInitialRoute(tabItem),
      onGenerateRoute: _getRoute,
      onUnknownRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) => NotFoundPage());
      },
    );
  }
}
