import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/board_detail/board_detail_page.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/view/list_widget_board.dart';

import 'bloc/board_list_bloc.dart';
import 'bloc/board_list_event.dart';
import 'bloc/board_list_state.dart';

class BoardListPage extends BasePage {
  @override
  _BoardListPageState createState() => _BoardListPageState();
}

class _BoardListPageState extends BasePageState<BoardListPage> {
  BoardListBloc _boardListBloc;
  Completer<void> _refreshCompleter;

  @override
  void initState() {
    super.initState();
    _boardListBloc = BlocProvider.of<BoardListBloc>(context);
    _boardListBloc.dispatch(BoardListEventFetchBoards());
    _refreshCompleter = Completer<void>();
  }

  @override
  void dispose() {
    _boardListBloc.dispose();
    super.dispose();
  }

  @override
  String getPageTitle() => "Boards";

  @override
  Widget buildBody() {
    return BlocBuilder<BoardListBloc, BoardListState>(
      builder: (context, state) {
        if (state is BoardListStateLoading) {
          return Center(child: Constants.progressIndicator);
        }

        _refreshCompleter?.complete();
        _refreshCompleter = Completer();
        return RefreshIndicator(
            onRefresh: () {
              _boardListBloc.dispatch(BoardListEventFetchBoards());
              return _refreshCompleter.future;
            },
            child: _buildContent(state));
      },
    );
  }

  Widget _buildContent(BoardListState state) {
    if (state is BoardListStateContent) {
      if (state.otherBoards.isEmpty) {
        return Center(child: Text('No boards'));
      }

      bool hasFavorites = state.favoriteBoards.isNotEmpty;
      int totalCount = hasFavorites ? (state.otherBoards.length + state.favoriteBoards.length + 1) : state.otherBoards.length;
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          Widget child;
          GestureTapCallback onTap;

          if (hasFavorites) {
            if (index == 0)
              child = Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Favorites", style: Theme.of(context).textTheme.subhead),
              );
            else if (index < state.favoriteBoards.length + 1) {
              child = BoardListWidget(state.favoriteBoards[index - 1]);
              onTap = (() => _openBoardDetailPage(state.favoriteBoards[index - 1].boardId));
            } else if (index == state.favoriteBoards.length + 1)
              child = Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Others", style: Theme.of(context).textTheme.subhead),
              );
            else {
              child = BoardListWidget(state.otherBoards[index - 2]);
              onTap = (() => _openBoardDetailPage(state.otherBoards[index - 2].boardId));
            }
          } else {
            child = BoardListWidget(state.otherBoards[index]);
          }
          return InkWell(
            child: child,
            onTap: onTap,
          );
        },
        itemCount: totalCount,
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
}
