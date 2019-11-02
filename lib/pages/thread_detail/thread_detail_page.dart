import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/app_bloc/app_bloc.dart';
import 'package:flutter_chan_viewer/bloc/app_bloc/app_event.dart';
import 'package:flutter_chan_viewer/models/posts_model.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:flutter_chan_viewer/view/grid_widget_post.dart';
import 'package:flutter_chan_viewer/view/list_widget_post.dart';
import 'package:flutter_chan_viewer/pages/gallery/gallery_page.dart';
import 'package:http/http.dart';
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
  bool _isFavorite = false;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _threadDetailBloc = BlocProvider.of<ThreadDetailBloc>(context);
    _threadDetailBloc.dispatch(ThreadDetailEventAppStarted());
    _threadDetailBloc.dispatch(ThreadDetailEventFetchPosts(true, widget.boardId, widget.threadId));
    _refreshCompleter = Completer<void>();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _catalogMode = prefs.getBool(Preferences.KEY_THREAD_CATALOG_MODE) ?? false;
        _isFavorite = (prefs.getStringList(Preferences.KEY_FAVORITE_THREADS) ?? []).contains(widget.threadId.toString());
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
      IconButton(icon: _catalogMode ? Icon(Icons.list) : Icon(Icons.apps), onPressed: _onCatalogModeToggleClick),
      IconButton(icon: _isFavorite ? Icon(Icons.star) : Icon(Icons.star_border), onPressed: _onFavoriteToggleClick)
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

  void _onFavoriteToggleClick() {
    bool newState = !_isFavorite;
    SharedPreferences.getInstance().then((prefs) {
      List<String> favoriteThreads = prefs.getStringList(Preferences.KEY_FAVORITE_THREADS) ?? [];
      favoriteThreads.removeWhere((value) => value == widget.threadId.toString());
      if (newState) {
        favoriteThreads.add(widget.threadId.toString());
      }
      prefs.setStringList(Preferences.KEY_FAVORITE_THREADS, favoriteThreads);
    });
    setState(() {
      _isFavorite = newState;
    });
  }

  @override
  Widget buildBody() {
    return BlocBuilder<ThreadDetailBloc, ThreadDetailState>(
      bloc: _threadDetailBloc,
      builder: (context, state) {
        if (state is ThreadDetailStateLoading) {
          return Center(
            child: Constants.progressIndicator,
          );
        }
        if (state is ThreadDetailStateContent) {
          if (state.data.posts.isEmpty) {
            return Center(
              child: Text('No posts'),
            );
          }

          _refreshCompleter?.complete();
          _refreshCompleter = Completer();

          return RefreshIndicator(
            onRefresh: () {
              _threadDetailBloc.dispatch(ThreadDetailEventFetchPosts(true, widget.boardId, widget.threadId));
              return _refreshCompleter.future;
            },
            child: Scrollbar(
              child: _catalogMode ? buildGrid(state.data.mediaPosts) : buildList(state.data.posts),
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
          onTap: () => _onItemTap(posts[index]),
        );
      },
      padding: EdgeInsets.all(0.0),
      itemCount: posts.length,
      controller: _scrollController,
    );
  }

  Widget buildGrid(List<ChanPost> mediaPosts) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    List<Widget> tiles = mediaPosts.map((post) => InkWell(child: PostGridWidget(post), onTap: () => _onItemTap(post))).toList();

    return GridView.count(
      crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
      mainAxisSpacing: 0.0,
      crossAxisSpacing: 0.0,
      padding: const EdgeInsets.all(0.0),
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

  void _onItemTap(ChanPost post) async {
    await Navigator.pushNamed(
      context,
      Constants.galleryRoute,
      arguments: GalleryPage.getArguments(widget.boardId, widget.threadId, post.postId),
    );

    BlocProvider.of<AppBloc>(context).dispatch(AppEventShowBottomBar(true));
  }
}
