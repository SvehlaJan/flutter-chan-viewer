import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/gallery/gallery_page.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/view/grid_widget_post.dart';
import 'package:flutter_chan_viewer/view/list_widget_post.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'bloc/thread_detail_bloc.dart';
import 'bloc/thread_detail_event.dart';
import 'bloc/thread_detail_state.dart';

class ThreadDetailPage extends StatefulWidget {
  static const String ARG_BOARD_ID = "ThreadDetailPage.ARG_BOARD_ID";
  static const String ARG_THREAD_ID = "ThreadDetailPage.ARG_THREAD_ID";
  static const String ARG_SHOW_DOWNLOADS_ONLY = "ThreadDetailPage.ARG_SHOW_DOWNLOADS_ONLY";

  static Map<String, dynamic> createArguments(
    final String boardId,
    final int threadId, {
    final bool showDownloadsOnly = false,
  }) {
    Map<String, dynamic> arguments = {ARG_BOARD_ID: boardId, ARG_THREAD_ID: threadId, ARG_SHOW_DOWNLOADS_ONLY: showDownloadsOnly};
    return arguments;
  }

  @override
  _ThreadDetailPageState createState() => _ThreadDetailPageState();
}

class _ThreadDetailPageState extends BasePageState<ThreadDetailPage> {
  static const String KEY_LIST = "_ThreadDetailPageState.KEY_LIST";
  static const String KEY_GRID = "_ThreadDetailPageState.KEY_GRID";

  ThreadDetailBloc _threadDetailBloc;
  ScrollController _gridScrollController;
  ItemScrollController _listScrollController;
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _threadDetailBloc = BlocProvider.of<ThreadDetailBloc>(context);
    _threadDetailBloc.add(ChanEventInitBloc());

    _gridScrollController = ScrollController();
    _listScrollController = ItemScrollController();
  }

  @override
  String getPageTitle() => _threadDetailBloc.pageTitle;

  List<PageAction> getPageActions(BuildContext context) => [
        _threadDetailBloc.isFavorite ? PageAction("Unstar", Icons.star, _onFavoriteToggleClick) : PageAction("Star", Icons.star_border, _onFavoriteToggleClick),
        PageAction("Refresh", Icons.refresh, _onRefreshClick),
        _threadDetailBloc.catalogMode ? PageAction("Show as list", Icons.list, _onCatalogModeToggleClick) : PageAction("Show catalog", Icons.apps, _onCatalogModeToggleClick),
      ];

  void _onRefreshClick() => _threadDetailBloc.add(ChanEventFetchData());

  void _onCatalogModeToggleClick() => _threadDetailBloc.add(ThreadDetailEventToggleCatalogMode());

  void _onFavoriteToggleClick() => _threadDetailBloc.add(ThreadDetailEventToggleFavorite());

  @override
  Widget build(BuildContext context) {
    return buildScaffold(
      context,
      BlocConsumer<ThreadDetailBloc, ChanState>(listener: (context, state) {
        if (state is ThreadDetailStateContent && state.event != null) {
          switch (state.event) {
            case ThreadDetailSingleEvent.SHOW_UNSTAR_WARNING:
              showConfirmUnstarDialog();
              break;
            case ThreadDetailSingleEvent.SCROLL_TO_SELECTED:
              scrollToSelectedPost(state.selectedPostIndex, state.selectedMediaIndex);
              break;
            case ThreadDetailSingleEvent.CLOSE_PAGE:
              Navigator.of(context).pop();
              break;
            case ThreadDetailSingleEvent.SHOW_OFFLINE:
              showOfflineSnackbar(context);
              break;
            default:
              break;
          }
        }
      }, builder: (context, state) {
        return BlocBuilder<ThreadDetailBloc, ChanState>(cubit: _threadDetailBloc, builder: (context, state) => buildBody(context, state));
      }),
      pageActions: getPageActions(context),
    );
  }

  Widget buildBody(BuildContext context, ChanState state) {
    if (state is ChanStateLoading) {
      return Constants.centeredProgressIndicator;
    }
    if (state is ThreadDetailStateContent) {
      if (state.model.visiblePosts.isEmpty) {
        return Constants.noDataPlaceholder;
      }

      return Stack(
        children: <Widget>[
          state.catalogMode ? buildGrid(context, state.model.visibleMediaPosts, state.selectedMediaIndex) : buildList(context, state.model.visiblePosts, state.selectedPostIndex),
          if (state.showLazyLoading) LinearProgressIndicator()
        ],
      );
    } else {
      return BasePageState.buildErrorScreen(context, (state as ChanStateError)?.message);
    }
  }

  Widget buildList(BuildContext context, List<PostItem> posts, int selectedPostIndex) {
    // return DraggableScrollbar.semicircle(child: null, controller: _listScrollController);
    return ScrollablePositionedList.builder(
      key: PageStorageKey<String>(KEY_LIST),
      itemCount: posts.length,
      itemScrollController: _listScrollController,
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

  Widget buildGrid(BuildContext context, List<PostItem> mediaPosts, int selectedMediaIndex) {
    return DraggableScrollbar.semicircle(
      controller: _gridScrollController,
      child: GridView.builder(
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
      ),
    );
  }

  void showConfirmUnstarDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Warning"),
            content: Text("This will delete downloaded content for this thread"),
            actions: [
              FlatButton(
                  child: Text("Cancel".toUpperCase()),
                  onPressed: () {
                    _threadDetailBloc.add(ThreadDetailEventDialogAnswered(false));
                    Navigator.of(context).pop();
                  }),
              FlatButton(
                  child: Text("OK, delete".toUpperCase()),
                  onPressed: () {
                    _threadDetailBloc.add(ThreadDetailEventDialogAnswered(true));
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
  }

  void scrollToSelectedPost(int selectedPostIndex, int selectedMediaIndex) {
    if (selectedPostIndex < 0) {
      return;
    }

    // TODO - dirty! Find a way how to scroll when list/grid is already shown
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_threadDetailBloc.catalogMode) {
        _gridScrollController.animateTo(_getGridScrollOffset(selectedMediaIndex), duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
      } else {
        _listScrollController.scrollTo(index: selectedPostIndex, duration: Duration(milliseconds: 500), alignment: 0.5);
      }
    });
  }

  double _getGridScrollOffset(int mediaIndex) {
    double itemHeight = MediaQuery.of(context).size.width / _getGridColumnCount();
    int targetRow = mediaIndex ~/ _getGridColumnCount();
    return targetRow * itemHeight - itemHeight;
  }

  int _getGridColumnCount() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return (orientation == Orientation.portrait) ? 2 : 3;
  }

  void _onItemTap(PostItem post, BuildContext context) {
    _threadDetailBloc.add(ThreadDetailEventOnPostSelected(null, post.postId));

    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => BlocProvider.value(
              value: _threadDetailBloc,
              child: GalleryPage(showAsReply: false),
            )));
  }

  void _onLinkClicked(String url, BuildContext context) => _threadDetailBloc.add(ThreadDetailEventOnLinkClicked(url));
}
