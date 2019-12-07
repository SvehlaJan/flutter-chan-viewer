import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_viewer_bloc/chan_viewer_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_viewer_bloc/chan_viewer_event.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/gallery/gallery_page_2.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/view/grid_widget_post.dart';
import 'package:flutter_chan_viewer/view/list_widget_post.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
//import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'bloc/thread_detail_bloc.dart';
import 'bloc/thread_detail_event.dart';
import 'bloc/thread_detail_state.dart';

class ThreadDetailPage extends BasePage {
  static const String ARG_BOARD_ID = "ThreadDetailPage.ARG_BOARD_ID";
  static const String ARG_THREAD_ID = "ThreadDetailPage.ARG_THREAD_ID";

  final String boardId;
  final int threadId;

  ThreadDetailPage(this.boardId, this.threadId);

  @override
  _ThreadDetailPageState createState() => _ThreadDetailPageState();
}

class _ThreadDetailPageState extends BasePageState<ThreadDetailPage> {
  ThreadDetailBloc _threadDetailBloc;
  final ItemScrollController itemScrollController = ItemScrollController();
  Completer<void> _refreshCompleter = Completer<void>();
//  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _threadDetailBloc = BlocProvider.of<ThreadDetailBloc>(context);
    _threadDetailBloc.add(ThreadDetailEventFetchPosts(false));
  }

  @override
  String getPageTitle() => "/${widget.boardId}/${widget.threadId}";

  @override
  List<Widget> getPageActions() {
    return [
      IconButton(icon: _threadDetailBloc.catalogMode ? Icon(Icons.list) : Icon(Icons.apps), onPressed: _onCatalogModeToggleClick),
      IconButton(icon: _threadDetailBloc.isFavorite ? Icon(Icons.star) : Icon(Icons.star_border), onPressed: _onFavoriteToggleClick)
    ];
  }

  void _onCatalogModeToggleClick() {
    _threadDetailBloc.add(ThreadDetailEventToggleCatalogMode());
  }

  void _onFavoriteToggleClick() {
    _threadDetailBloc.add(ThreadDetailEventToggleFavorite());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThreadDetailBloc, ThreadDetailState>(bloc: _threadDetailBloc, builder: (context, state) => buildPage(buildBody(context, state)));
  }

  Widget buildBody(BuildContext context, ThreadDetailState state) {
    if (state is ThreadDetailStateLoading) {
      return Constants.centeredProgressIndicator;
    }
    if (state is ThreadDetailStateContent) {
      if (state.model.posts.isEmpty) {
        return Constants.noDataPlaceholder;
      }

      _refreshCompleter?.complete();
      _refreshCompleter = Completer();

      return RefreshIndicator(
//        enablePullUp: true,
//        enablePullDown: true,
//        header: WaterDropHeader(),
//        controller: _refreshController,
        onRefresh: () {
          print("onRefresh");
//          _threadDetailBloc.add(ThreadDetailEventFetchPosts(true));
//          _refreshController.refreshCompleted();
          return _refreshCompleter.future;
        },
//        onLoading: () {
//          print("onLoading");
//          _refreshController.loadComplete();
//        },
        child: Scrollbar(
          child: state.catalogMode ? buildGrid(context, state.model.mediaPosts) : buildList(context, state.model.posts, state.selectedPostIndex),
        ),
      );
    } else {
      return Constants.errorPlaceholder;
    }
  }

  Widget buildList(BuildContext context, List<ChanPost> posts, int selectedPostIndex) {
    return ScrollablePositionedList.builder(
      itemCount: posts.length,
      itemScrollController: itemScrollController,
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

  Widget buildGrid(BuildContext context, List<ChanPost> mediaPosts) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    List<Widget> tiles = mediaPosts.map((post) => InkWell(child: PostGridWidget(post), onTap: () => _onItemTap(post))).toList();

    return GridView.count(
      crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
      mainAxisSpacing: 0.0,
      crossAxisSpacing: 0.0,
      padding: const EdgeInsets.all(0.0),
      childAspectRatio: (orientation == Orientation.portrait) ? 1.0 : 1.3,
      children: tiles,
    );
  }

  void scrollToIndex(int index) {
    if (!_threadDetailBloc.catalogMode) {
//      itemScrollController.scrollTo(index: index, duration: Duration(milliseconds: 500), alignment: 500.0);
      itemScrollController.jumpTo(index: index, alignment: 0.5);
    }
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
    int newIndex = _threadDetailBloc.selectedPostIndex;
    scrollToIndex(newIndex);
  }
}
