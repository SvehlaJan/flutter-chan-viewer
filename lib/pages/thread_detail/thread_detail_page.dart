import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_viewer_bloc/chan_viewer_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_viewer_bloc/chan_viewer_event.dart';
import 'package:flutter_chan_viewer/models/chan_post.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/gallery/gallery_page_2.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/view/grid_widget_post.dart';
import 'package:flutter_chan_viewer/view/list_widget_post.dart';
import 'package:flutter_widgets/flutter_widgets.dart';

import 'bloc/thread_detail_bloc.dart';
import 'bloc/thread_detail_event.dart';
import 'bloc/thread_detail_state.dart';

class ThreadDetailPage extends BasePage {
  static const String ARG_BOARD_ID = "ThreadDetailPage.ARG_BOARD_ID";
  static const String ARG_THREAD_ID = "ThreadDetailPage.ARG_THREAD_ID";
  static const String ARG_SHOW_DOWNLOADS_ONLY = "ThreadDetailPage.ARG_SHOW_DOWNLOADS_ONLY";

  final String boardId;
  final int threadId;

  static Map<String, dynamic> getArguments(final String boardId, final int threadId, final bool showDownloadsOnly) => {
        ARG_BOARD_ID: boardId,
        ARG_THREAD_ID: threadId,
        ARG_SHOW_DOWNLOADS_ONLY: showDownloadsOnly,
      };

  ThreadDetailPage(this.boardId, this.threadId);

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
  String getPageTitle() => "/${widget.boardId}/${widget.threadId}";

  @override
  List<AppBarAction> getAppBarActions(BuildContext context) => [
        AppBarAction("Refresh", Icons.refresh, _onRefreshClick),
        _threadDetailBloc.catalogMode ? AppBarAction("List", Icons.list, _onCatalogModeToggleClick) : AppBarAction("Catalog", Icons.apps, _onCatalogModeToggleClick),
        _threadDetailBloc.isFavorite ? AppBarAction("Unstar", Icons.star_border, _onFavoriteToggleClick) : AppBarAction("Star", Icons.star, _onFavoriteToggleClick),
        AppBarAction("Download", Icons.file_download, _onDownloadClick)
      ];

  void _onRefreshClick() => _threadDetailBloc.add(ThreadDetailEventFetchPosts(true));

  void _onCatalogModeToggleClick() => _threadDetailBloc.add(ThreadDetailEventToggleCatalogMode());

  void _onFavoriteToggleClick() => _threadDetailBloc.add(ThreadDetailEventToggleFavorite());

  void _onDownloadClick() => _threadDetailBloc.add(ThreadDetailEventDownload());

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThreadDetailBloc, ThreadDetailState>(bloc: _threadDetailBloc, builder: (context, state) => buildPage(context, buildBody(context, state)));
  }

  Widget buildBody(BuildContext context, ThreadDetailState state) {
    if (state is ThreadDetailStateLoading) {
      return Constants.centeredProgressIndicator;
    }
    if (state is ThreadDetailStateContent) {
      if (state.model.posts.isEmpty) {
        return Constants.noDataPlaceholder;
      }

      return Column(
        children: <Widget>[
          Flexible(
            child: Scrollbar(
              child: state.catalogMode
                  ? buildGrid(
                      context,
                      state.model.mediaPosts,
                      state.selectedMediaIndex,
                    )
                  : buildList(
                      context,
                      state.model.posts,
                      state.selectedPostIndex,
                    ),
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
        return InkWell(
          child: PostListWidget(posts[index], index == selectedPostIndex),
          onTap: () => _onItemTap(posts[index]),
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
        return InkWell(
          child: PostGridWidget(mediaPosts[index], index == selectedMediaIndex),
          onTap: () => _onItemTap(mediaPosts[index]),
        );
      },
    );
  }

  void scrollToSelectedPost() {
    if (_threadDetailBloc.catalogMode) {
      _gridScrollController.jumpTo(_getGridScrollOffset());
    } else {
      _listScrollController.jumpTo(index: _threadDetailBloc.selectedPostIndex, alignment: 0.5);
    }

//      _gridScrollController.animateTo(targetRow * itemHeight, duration: Duration(milliseconds: 500), curve: Curves.elasticInOut);
//      _listScrollController.scrollTo(index: index, duration: Duration(milliseconds: 500), alignment: 0.5);
  }

  double _getGridScrollOffset() {
    int mediaIndex = _threadDetailBloc.selectedMediaIndex;
    double itemHeight = MediaQuery.of(context).size.width / _getGridColumnCount();
    int targetRow = mediaIndex ~/ _getGridColumnCount();
    return targetRow * itemHeight;
  }

  int _getGridColumnCount() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return (orientation == Orientation.portrait) ? 2 : 3;
  }

  void _onItemTap(ChanPost post) async {
    _threadDetailBloc.add(ThreadDetailEventOnPostSelected(null, post.postId));
//    _threadDetailBloc.selectedPostId = post.postId;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => BlocProvider.value(
          value: _threadDetailBloc,
          child: GalleryPage(),
        ),
      ),
    );

    BlocProvider.of<ChanViewerBloc>(context).add(ChanViewerEventShowBottomBar(true));
    scrollToSelectedPost();
  }
}
