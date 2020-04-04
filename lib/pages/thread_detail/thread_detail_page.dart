import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/models/chan_post.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/gallery/gallery_page.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/view/grid_widget_post.dart';
import 'package:flutter_chan_viewer/view/list_widget_post.dart';
import 'package:flutter_widgets/flutter_widgets.dart';

import 'bloc/thread_detail_bloc.dart';
import 'bloc/thread_detail_event.dart';
import 'bloc/thread_detail_state.dart';

class ThreadDetailPage extends StatefulWidget {
  static const String ARG_BOARD_ID = "ThreadDetailPage.ARG_BOARD_ID";
  static const String ARG_THREAD_ID = "ThreadDetailPage.ARG_THREAD_ID";
  static const String ARG_SHOW_APP_BAR = "ThreadDetailPage.ARG_SHOW_APP_BAR";
  static const String ARG_SHOW_DOWNLOADS_ONLY = "ThreadDetailPage.ARG_SHOW_DOWNLOADS_ONLY";
  static const String ARG_CATALOG_MODE = "ThreadDetailPage.ARG_CATALOG_MODE";
  static const String ARG_PRESELECTED_POST_ID = "ThreadDetailPage.ARG_PRESELECTED_POST_ID";

  static Map<String, dynamic> createArguments(final String boardId, final int threadId,
      {bool showAppBar = true, final bool showDownloadsOnly = false, final bool catalogMode, final int preSelectedPostId = -1}) {
    Map<String, dynamic> arguments = {
      ARG_BOARD_ID: boardId,
      ARG_THREAD_ID: threadId,
      ARG_SHOW_APP_BAR: showAppBar,
      ARG_SHOW_DOWNLOADS_ONLY: showDownloadsOnly,
      ARG_PRESELECTED_POST_ID: preSelectedPostId
    };
    if (preSelectedPostId != null) {
      arguments[ARG_PRESELECTED_POST_ID] = preSelectedPostId;
    }
    if (catalogMode != null) {
      arguments[ARG_CATALOG_MODE] = catalogMode;
    }
    return arguments;
  }

  @override
  _ThreadDetailPageState createState() => _ThreadDetailPageState();
}

class _ThreadDetailPageState extends BasePageState<ThreadDetailPage> {
  static const String KEY_LIST = "KEY_LIST";
  static const String KEY_GRID = "KEY_GRID";

  ThreadDetailBloc _threadDetailBloc;
  ScrollController _gridScrollController;
  ItemScrollController _listScrollController;

  @override
  void initState() {
    super.initState();
    _threadDetailBloc = BlocProvider.of<ThreadDetailBloc>(context);
    _threadDetailBloc.add(ThreadDetailEventFetchPosts(false));

    _gridScrollController = ScrollController();
    _listScrollController = ItemScrollController();
  }

  @override
  String getPageTitle() => _threadDetailBloc.pageTitle;

  @override
  List<AppBarAction> getAppBarActions(BuildContext context) => [
        _threadDetailBloc.isFavorite ? AppBarAction("Unstar", Icons.star, _onFavoriteToggleClick) : AppBarAction("Star", Icons.star_border, _onFavoriteToggleClick),
        AppBarAction("Refresh", Icons.refresh, _onRefreshClick),
        _threadDetailBloc.catalogMode ? AppBarAction("List", Icons.list, _onCatalogModeToggleClick) : AppBarAction("Catalog", Icons.apps, _onCatalogModeToggleClick),
        AppBarAction("Download", Icons.file_download, _onDownloadClick)
      ];

  void _onRefreshClick() => _threadDetailBloc.add(ThreadDetailEventFetchPosts(true));

  void _onCatalogModeToggleClick() => _threadDetailBloc.add(ThreadDetailEventToggleCatalogMode());

  void _onFavoriteToggleClick() => _threadDetailBloc.add(ThreadDetailEventToggleFavorite());

  void _onDownloadClick() => _threadDetailBloc.add(ThreadDetailEventDownload());

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThreadDetailBloc, ThreadDetailState>(
        bloc: _threadDetailBloc,
        builder: (context, state) {
          if (state is ThreadDetailStateContent && !state.showAppBar) {
            return buildBody(context, state);
          }
          return buildScaffold(context, buildBody(context, state));
        });
  }

  Widget buildBody(BuildContext context, ThreadDetailState state) {
    if (state is ThreadDetailStateLoading) {
      return Constants.centeredProgressIndicator;
    }
    if (state is ThreadDetailStateContent) {
      if (state.model.posts.isEmpty) {
        return Constants.noDataPlaceholder;
      }

      scrollToSelectedPost();

      return Column(
        children: <Widget>[
          Flexible(
            child: Scrollbar(
              child: state.catalogMode ? buildGrid(context, state.model.mediaPosts, state.selectedMediaIndex) : buildList(context, state.model.posts, state.selectedPostIndex),
            ),
          ),
          if (state.lazyLoading) LinearProgressIndicator()
        ],
      );
    } else {
      return Constants.errorPlaceholder;
    }
  }

  Widget buildList(BuildContext context, List<ChanPost> posts, int selectedPostIndex) {
    return ScrollablePositionedList.builder(
      itemCount: posts.length,
      itemScrollController: _listScrollController,
      initialScrollIndex: max(0, selectedPostIndex),
      itemBuilder: (context, index) {
        return PostListWidget(
          post: posts[index],
          selected: index == selectedPostIndex,
          onTap: () => _onItemTap(posts[index], context),
          onLinkTap: (url) => _onLinkClicked(url, context),
        );
      },
      padding: EdgeInsets.all(0.0),
    );
  }

  Widget buildGrid(BuildContext context, List<ChanPost> mediaPosts, int selectedMediaIndex) {
    return GridView.builder(
      key: PageStorageKey<String>(KEY_GRID),
      controller: _gridScrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getGridColumnCount(),
        mainAxisSpacing: 0.0,
        crossAxisSpacing: 0.0,
        childAspectRatio: 1.0,
      ),
      padding: const EdgeInsets.all(0.0),
      itemCount: mediaPosts.length,
      itemBuilder: (BuildContext context, int index) {
        return PostGridWidget(
          post: mediaPosts[index],
          selected: index == selectedMediaIndex,
          onTap: () => _onItemTap(mediaPosts[index], context),
        );
      },
    );
  }

  void scrollToSelectedPost() {
    // TODO - dirty! Fix
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_threadDetailBloc.catalogMode) {
//      _gridScrollController.jumpTo(_getGridScrollOffset());
        _gridScrollController.animateTo(_getGridScrollOffset(), duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
      } else {
//      _listScrollController.jumpTo(index: _threadDetailBloc.selectedPostIndex, alignment: 0.5);
        _listScrollController.scrollTo(index: _threadDetailBloc.selectedPostIndex, duration: Duration(milliseconds: 500), alignment: 0.5);
      }
    });
  }

  double _getGridScrollOffset() {
    int mediaIndex = _threadDetailBloc.selectedMediaIndex;
    double itemHeight = MediaQuery.of(context).size.width / _getGridColumnCount();
    int targetRow = mediaIndex ~/ _getGridColumnCount();
    return targetRow * itemHeight - itemHeight;
  }

  int _getGridColumnCount() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return (orientation == Orientation.portrait) ? 2 : 3;
  }

  void _onItemTap(ChanPost post, BuildContext context) {
    _threadDetailBloc.add(ThreadDetailEventOnPostSelected(null, post.postId));

    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => BlocProvider.value(
              value: _threadDetailBloc,
              child: GalleryPage(),
            )));
  }

  void _onLinkClicked(String url, BuildContext context) => _threadDetailBloc.add(ThreadDetailEventOnLinkClicked(url));
}
