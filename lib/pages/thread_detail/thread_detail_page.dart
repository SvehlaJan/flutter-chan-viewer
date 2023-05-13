import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/helper/online_state.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/gallery/bloc/gallery_bloc.dart';
import 'package:flutter_chan_viewer/pages/gallery/gallery_page.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/view/grid_widget_post.dart';
import 'package:flutter_chan_viewer/view/list_widget_post.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'bloc/thread_detail_bloc.dart';
import 'bloc/thread_detail_event.dart';
import 'bloc/thread_detail_state.dart';

class ThreadDetailPage extends StatefulWidget {
  static const String ARG_BOARD_ID = "ThreadDetailPage.ARG_BOARD_ID";
  static const String ARG_THREAD_ID = "ThreadDetailPage.ARG_THREAD_ID";
  static const String ARG_SHOW_DOWNLOADS_ONLY = "ThreadDetailPage.ARG_SHOW_DOWNLOADS_ONLY";

  final String? boardId;
  final int? threadId;

  ThreadDetailPage(this.boardId, this.threadId);

  static Map<String, dynamic> createArguments(
    final String boardId,
    final int threadId, {
    final bool showDownloadsOnly = false,
  }) {
    Map<String, dynamic> arguments = {
      ARG_BOARD_ID: boardId,
      ARG_THREAD_ID: threadId,
      ARG_SHOW_DOWNLOADS_ONLY: showDownloadsOnly
    };
    return arguments;
  }

  @override
  _ThreadDetailPageState createState() => _ThreadDetailPageState();
}

class _ThreadDetailPageState extends BasePageState<ThreadDetailPage> {
  static const String KEY_LIST = "_ThreadDetailPageState.KEY_LIST";
  static const String KEY_GRID = "_ThreadDetailPageState.KEY_GRID";

  late ScrollController _gridScrollController;
  late ItemScrollController _listScrollController;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<ThreadDetailBloc>(context);
    bloc.add(ChanEventInitBloc());

    _gridScrollController = ScrollController();
    _listScrollController = ItemScrollController();
  }

  @override
  String getPageTitle() => "/${widget.boardId}/${widget.threadId}";

  List<PageAction> getPageActions(BuildContext context, ChanState state) {
    bool showSearchButton = state is ThreadDetailStateContent && !state.showSearchBar;
    bool isFavorite = state is ThreadDetailStateContent && state.isFavorite;
    bool isCatalogMode = state is ThreadDetailStateContent && state.catalogMode;
    bool isCollection =
        state is ThreadDetailStateContent && state.model.thread.onlineStatus == OnlineState.CUSTOM.index;
    List<PageAction> actions = [if (showSearchButton) PageAction("Search", Icons.search, _onSearchClick)];
    if (isCollection) {
      actions.add(PageAction("Delete collection", Icons.delete_forever,
          () => _onDeleteCollectionClicked(context, state.model.thread.threadId)));
    } else {
      actions.add(isFavorite
          ? PageAction("Unstar", Icons.star, _onFavoriteToggleClick)
          : PageAction("Star", Icons.star_border, _onFavoriteToggleClick));
    }
    actions.add(isCatalogMode
        ? PageAction("Show as list", Icons.list, _onCatalogModeToggleClick)
        : PageAction("Show catalog", Icons.apps, _onCatalogModeToggleClick));
    actions.add(PageAction("Refresh", Icons.refresh, _onRefreshClick));
    return actions;
  }

  void _onSearchClick() => startSearch();

  void _onRefreshClick() => bloc.add(ChanEventFetchData());

  void _onCatalogModeToggleClick() => bloc.add(ThreadDetailEventToggleCatalogMode());

  void _onFavoriteToggleClick() => bloc.add(ThreadDetailEventToggleFavorite(confirmed: false));

  void _onDeleteCollectionClicked(BuildContext context, int threadId) => showConfirmCollectionDeleteDialog(threadId);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ThreadDetailBloc, ChanState>(
      listener: (context, state) {
        if (state is ThreadDetailStateContent && state.event != null) {
          switch (state.event) {
            case ThreadDetailSingleEvent.SHOW_UNSTAR_WARNING:
              showConfirmUnstarDialog();
              break;
            case ThreadDetailSingleEvent.SCROLL_TO_SELECTED:
              scrollToSelectedPost(state.selectedPostIndex, state.selectedMediaIndex, state);
              break;
            case ChanSingleEvent.CLOSE_PAGE:
              Navigator.of(context).pop();
              break;
            case ChanSingleEvent.SHOW_OFFLINE:
              showOfflineSnackbar(context);
              break;
            default:
              break;
          }
        }
      },
      builder: (context, state) {
        return BlocBuilder<ThreadDetailBloc, ChanState>(
            bloc: bloc as ThreadDetailBloc?,
            builder: (context, state) {
              return buildScaffold(
                context,
                buildBody(context, state),
                pageActions: getPageActions(context, state),
                showSearchBar: state.showSearchBar,
              );
            });
      },
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
          state.catalogMode
              ? buildGrid(context, state.model.visibleMediaPosts, state.selectedMediaIndex)
              : buildList(context, state.model.visiblePosts, state.selectedPostIndex),
          if (state.showLazyLoading) LinearProgressIndicator(),
        ],
      );
    } else {
      return BasePageState.buildErrorScreen(context, (state as ChanStateError).message);
    }
  }

  Widget buildList(BuildContext context, List<PostItem> posts, int selectedPostIndex) {
    return ScrollablePositionedList.builder(
      key: PageStorageKey<String>(KEY_LIST),
      itemCount: posts.length,
      itemScrollController: _listScrollController,
      itemBuilder: (context, index) {
        PostItem post = posts[index];
        Key itemKey = ValueKey(post.postId);
        return PostListWidget(
          post: post,
          selected: index == selectedPostIndex,
          onTap: () => _onItemTap(context, post),
          onLongPress: () => _onItemLongPress(context, post, itemKey),
          onLinkTap: (url) => _onLinkClicked(url, context),
          showImage: true,
          showHeroAnimation: true,
        );
      },
      padding: EdgeInsets.all(0.0),
    );
  }

  Widget buildGrid(BuildContext context, List<PostItem> mediaPosts, int selectedMediaIndex) {
    return Scrollbar(
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
          PostItem post = mediaPosts[index];
          Key itemKey = ValueKey(post.postId);
          return PostGridWidget(
            key: itemKey,
            post: post,
            selected: index == selectedMediaIndex,
            onTap: () => _onItemTap(context, post),
            onLongPress: () => _onItemLongPress(context, post, itemKey),
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
              TextButton(
                  child: Text("Cancel".toUpperCase()),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              TextButton(
                  child: Text("OK, delete".toUpperCase()),
                  onPressed: () {
                    bloc.add(ThreadDetailEventToggleFavorite(confirmed: true));
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
  }

  void showConfirmCollectionDeleteDialog(int threadId) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Warning"),
            content: Text("This will also delete downloaded content from this collection"),
            actions: [
              TextButton(child: Text("Cancel".toUpperCase()), onPressed: () => Navigator.of(context).pop()),
              TextButton(
                  child: Text("OK, delete".toUpperCase()),
                  onPressed: () {
                    bloc.add(ThreadDetailEventDeleteCollection(threadId));
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
  }

  void scrollToSelectedPost(int selectedPostIndex, int selectedMediaIndex, ChanState state) {
    if (selectedPostIndex < 0) {
      return;
    }

    bool isCatalogMode = state is ThreadDetailStateContent && state.catalogMode;

    // TODO - dirty! Find a way how to scroll when list/grid is already shown
    Future.delayed(const Duration(milliseconds: 500), () {
      if (isCatalogMode) {
        _gridScrollController.animateTo(_getGridScrollOffset(selectedMediaIndex),
            duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
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

  void _onItemTap(BuildContext context, PostItem post) async {
    bloc.add(ThreadDetailEventOnPostSelected(post.postId));
    // // hack to wait for selected post to be propagated to state
    // await bloc.stream.first;

    Navigator.of(context).push(
      PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) {
            // return GalleryPage(
            //   showAsReply: false,
            //   initialPostId: post.postId,
            // );
            return BlocProvider(
              // value: BlocProvider.of<ThreadDetailBloc>(context),
              create: (context) => GalleryBloc(post.boardId, post.threadId, post.postId),
              child: GalleryPage(
                showAsReply: false,
              ),
            );
          }),
    );
  }

  void _onItemLongPress(BuildContext context, PostItem post, Key itemKey) {
    // PopupMenu.context = context;
    // PopupMenu menu = PopupMenu(
    //   items: [
    //     MenuItem(title: 'Hide post', image: Icon(Icons.visibility_off)),
    //     MenuItem(title: 'Collection', image: Icon(Icons.add)),
    //   ],
    //   onClickMenu: (MenuItemProvider item) {
    //     switch (item.menuTitle) {
    //       case "Hide post":
    //         bloc.add(ThreadDetailEventHidePost());
    //         break;
    //       case "Collection":
    //         bloc.add(ThreadDetailEventHidePost());
    //         break;
    //     }
    //   },
    // );
    //
    // menu.show(widgetKey: itemKey);
  }

  void _onLinkClicked(String url, BuildContext context) {
    bloc.add(ThreadDetailEventOnLinkClicked(url));
  }
}
