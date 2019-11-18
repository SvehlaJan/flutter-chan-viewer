import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/models/board_list_model.dart';
import 'package:flutter_chan_viewer/models/board_detail_model.dart';
import 'package:flutter_chan_viewer/pages/base/base_page_2.dart';
import 'package:flutter_chan_viewer/pages/board_detail/board_detail_page.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/thread_detail_page.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/view/list_widget_board.dart';
import 'package:flutter_chan_viewer/view/list_widget_thread.dart';

import 'bloc/favorites_bloc.dart';
import 'bloc/favorites_event.dart';
import 'bloc/favorites_state.dart';

class FavoritesPage extends BasePage {
  FavoritesPage();

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends BasePageState<FavoritesPage> {
  FavoritesBloc _favoritesBloc;
  Completer<void> _refreshCompleter;

  @override
  void initState() {
    super.initState();
    _favoritesBloc = BlocProvider.of<FavoritesBloc>(context);
    _favoritesBloc.add(FavoritesEventFetchData());
    _refreshCompleter = Completer<void>();
  }

  @override
  String getPageTitle() => "Favorites";

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(bloc: _favoritesBloc, builder: (context, state) => buildPage(buildBody(context, state)));
  }

  Widget buildBody(BuildContext context, FavoritesState state) {
    if (state is FavoritesStateLoading) {
      return Center(
        child: Constants.progressIndicator,
      );
    }
    if (state is FavoritesStateContent) {
      if (state.threads.isEmpty) {
        return Center(child: Text('No threads'));
      }

      _refreshCompleter?.complete();
      _refreshCompleter = Completer();
      return RefreshIndicator(
        onRefresh: () {
          _favoritesBloc.add(FavoritesEventFetchData());
          return _refreshCompleter.future;
        },
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            if (index < state.boards.length) {
              ChanBoard board = state.boards[index];
              return InkWell(
                child: BoardListWidget(board),
                onTap: () => _openBoardDetailPage(board.boardId),
              );
            } else {
              ChanThread thread = state.threads[index - state.boards.length];
              return InkWell(
                child: ThreadListWidget(thread),
                onTap: () => _openThreadDetailPage(thread),
              );
            }
          },
          itemCount: state.boards.length + state.threads.length,
        ),
      );
    } else {
      return Center(child: Text('Failed to fetch posts'));
    }
  }

  void _openBoardDetailPage(String boardId) {
    Navigator.pushNamed(
      context,
      Constants.boardDetailRoute,
      arguments: {
        BoardDetailPage.ARG_BOARD_ID: boardId,
      },
    );
  }

  void _openThreadDetailPage(ChanThread thread) {
    Navigator.pushNamed(
      context,
      Constants.threadDetailRoute,
      arguments: {
        ThreadDetailPage.ARG_BOARD_ID: thread.boardId,
        ThreadDetailPage.ARG_THREAD_ID: thread.threadId,
      },
    );
  }
}
