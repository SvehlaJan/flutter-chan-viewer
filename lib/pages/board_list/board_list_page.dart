import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/models/api/boards_model.dart';
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
    _boardListBloc.dispatch(BoardListEventAppStarted());
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
          return Center(child: CircularProgressIndicator());
        }
        if (state is BoardListStateContent) {
          if (state.boards.isEmpty) {
            return Center(child: Text('No boards'));
          }

          _refreshCompleter?.complete();
          _refreshCompleter = Completer();
          return RefreshIndicator(
            onRefresh: () {
              _boardListBloc.dispatch(BoardListEventFetchBoards());
              return _refreshCompleter.future;
            },
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  child: BoardListWidget(state.boards[index]),
                  onTap: () => _openBoardDetailPage(state.boards[index].boardId),
                );
              },
              itemCount: state.boards.length,
            ),
          );
        } else {
          return Center(child: Text('Failed to fetch posts'));
        }
      },
    );
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
