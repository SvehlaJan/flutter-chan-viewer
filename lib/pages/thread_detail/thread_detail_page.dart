import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/app_bloc/app_bloc.dart';
import 'package:flutter_chan_viewer/bloc/app_bloc/app_event.dart';
import 'package:flutter_chan_viewer/models/api/posts_model.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/view/grid_widget_post.dart';
import 'package:flutter_chan_viewer/view/list_widget_post.dart';
import 'package:flutter_chan_viewer/view/view_chan_gallery.dart';

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
  Completer<void> _refreshCompleter;

  @override
  void initState() {
    super.initState();
    _threadDetailBloc = BlocProvider.of<ThreadDetailBloc>(context);
    _threadDetailBloc.dispatch(ThreadDetailEventAppStarted());
    _threadDetailBloc.dispatch(ThreadDetailEventFetchPosts(widget.boardId, widget.threadId));
    _refreshCompleter = Completer<void>();
  }

  @override
  void dispose() {
    _threadDetailBloc.dispose();
    super.dispose();
  }

  @override
  String getPageTitle() => "Thread /${widget.boardId}/${widget.threadId}";

//  @override
//  Widget buildBody() {
//    return BlocBuilder<ThreadDetailBloc, ThreadDetailState>(
//      builder: (context, state) {
//        if (state is ThreadDetailStateLoading) {
//          return Center(
//            child: CircularProgressIndicator(),
//          );
//        }
//        if (state is ThreadDetailStateContent) {
//          if (state.posts.isEmpty) {
//            return Center(
//              child: Text('No posts'),
//            );
//          }
//          return ListView.builder(
//            itemBuilder: (BuildContext context, int index) {
//              return InkWell(
//                child: PostListWidget(state.posts[index]),
//                onTap: () => null,
//              );
//            },
//            padding: EdgeInsets.all(0.0),
//            itemCount: state.posts.length,
//          );
//        } else {
//          return Center(
//            child: Text('Failed to fetch posts'),
//          );
//        }
//      },
//    );
//  }

  @override
  Widget buildBody() {
    final Orientation orientation = MediaQuery.of(context).orientation;

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

          state.posts.removeWhere((post) => post.getImageUrl() == null);
          return RefreshIndicator(
            onRefresh: () {
              _threadDetailBloc.dispatch(ThreadDetailEventFetchPosts(widget.boardId, widget.threadId));
              return _refreshCompleter.future;
            },
            child: GridView.count(
              crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
              mainAxisSpacing: 2.0,
              crossAxisSpacing: 2.0,
              padding: const EdgeInsets.all(2.0),
              childAspectRatio: (orientation == Orientation.portrait) ? 1.0 : 1.3,
              children: state.posts.map<Widget>((ChanPost post) {
                return Hero(tag: post.getImageUrl(), child: PostGridWidget(post, () => _onItemTap(state.posts.toList(), state.posts.toList().indexOf(post))));
              }).toList(),
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

  void _onItemTap(List<ChanPost> posts, int index) async {
    ChanPost post = posts[index];

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
