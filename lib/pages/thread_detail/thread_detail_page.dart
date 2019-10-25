import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/app_bloc/app_bloc.dart';
import 'package:flutter_chan_viewer/bloc/app_bloc/app_event.dart';
import 'package:flutter_chan_viewer/models/api/posts_model.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:flutter_chan_viewer/view/grid_widget_post.dart';
import 'package:flutter_chan_viewer/view/list_widget_post.dart';
import 'package:flutter_chan_viewer/view/view_chan_gallery.dart';
import 'package:indexed_list_view/indexed_list_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final _scrollController = ScrollController();
  Completer<void> _refreshCompleter;
  bool _catalogMode = true;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _threadDetailBloc = BlocProvider.of<ThreadDetailBloc>(context);
    _threadDetailBloc.dispatch(ThreadDetailEventAppStarted());
    _threadDetailBloc.dispatch(ThreadDetailEventFetchPosts(widget.boardId, widget.threadId));
    _refreshCompleter = Completer<void>();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _catalogMode = prefs.getBool(Preferences.KEY_THREAD_CATALOG_MODE);
      });
    });
  }

  @override
  void dispose() {
    _threadDetailBloc.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  String getPageTitle() => "Thread /${widget.boardId}/${widget.threadId}";

  @override
  List<Widget> getPageActions() {
    print('Thread detail _catalogMode: $_catalogMode');
    Icon icon = _catalogMode ? Icon(Icons.list) : Icon(Icons.apps);
    return [
      IconButton(icon: icon, onPressed: _onCatalogModeToggleClick)
    ];
  }

  void _onCatalogModeToggleClick() {
    bool newVal = !_catalogMode;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(Preferences.KEY_THREAD_CATALOG_MODE, newVal);
      setState(() {
        _catalogMode = newVal;
      });
    });
  }

  @override
  Widget buildBody() {
    return BlocBuilder<ThreadDetailBloc, ThreadDetailState>(
      builder: (context, state) {
        if (state is ThreadDetailStateLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is ThreadDetailStateContent) {
          if (state.posts.isEmpty) {
            return Center(
              child: Text('No posts'),
            );
          }

          _refreshCompleter?.complete();
          _refreshCompleter = Completer();

          return RefreshIndicator(
            onRefresh: () {
              _threadDetailBloc.dispatch(ThreadDetailEventFetchPosts(widget.boardId, widget.threadId));
              return _refreshCompleter.future;
            },
            child: Scrollbar(
              child: _catalogMode ? buildGrid(state.posts) : buildList(state.posts),
            ),
          );
        } else {
          return Center(
            child: Text('Failed to fetch posts'),
          );
        }
      },
    );
  }

  Widget buildList(List<ChanPost> posts) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          child: PostListWidget(posts[index]),
          onTap: () => _onItemTap(posts, index),
        );
      },
      padding: EdgeInsets.all(0.0),
      itemCount: posts.length,
      controller: _scrollController,
    );
  }

  Widget buildGrid(List<ChanPost> posts) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    List<Widget> tiles = [];
    posts.asMap().forEach((index, post) {
      if (post.getImageUrl() != null) {
        tiles.add(Hero(tag: post.getImageUrl(), child: PostGridWidget(post, () => _onItemTap(posts.toList(), posts.toList().indexOf(post)))));
      }
    });

    return GridView.count(
      crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
      mainAxisSpacing: 2.0,
      crossAxisSpacing: 2.0,
      padding: const EdgeInsets.all(2.0),
      childAspectRatio: (orientation == Orientation.portrait) ? 1.0 : 1.3,
      children: tiles,
      controller: _scrollController,
    );
  }

  void scrollToIndex(int index) {
//    if (_catalogMode) {
//      _scrollController.jumpToIndex(index);
//    }
  }

  void _onItemTap(List<ChanPost> posts, int index) async {
    await Navigator.pushNamed(
      context,
      Constants.galleryRoute,
      arguments: {
        ChanGallery.ARG_POSTS: posts,
        ChanGallery.ARG_INITIAL_PAGE_INDEX: index,
      },
    );

    BlocProvider.of<AppBloc>(context).dispatch(AppEventShowBottomBar(true));
  }
}
