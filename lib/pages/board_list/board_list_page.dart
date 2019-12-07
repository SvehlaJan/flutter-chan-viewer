import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/board_detail/board_detail_page.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/view/list_widget_board.dart';
import 'package:flutter_widgets/flutter_widgets.dart';

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
  final ItemScrollController itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    _boardListBloc = BlocProvider.of<BoardListBloc>(context);
    _boardListBloc.add(BoardListEventFetchBoards(false));
    _refreshCompleter = Completer<void>();
  }

  @override
  String getPageTitle() => "Boards";

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoardListBloc, BoardListState>(bloc: _boardListBloc, builder: (context, state) => buildPage(buildBody(context, state)));
  }

  Widget buildBody(BuildContext context, BoardListState state) {
    if (state is BoardListStateLoading) {
      return Constants.centeredProgressIndicator;
    } else {
      _refreshCompleter?.complete();
      _refreshCompleter = Completer();
      return RefreshIndicator(
          onRefresh: () {
            _boardListBloc.add(BoardListEventFetchBoards(true));
            return _refreshCompleter.future;
          },
          child: _buildContent(context, state));
    }
  }

  Widget _buildContent(BuildContext context, BoardListState state) {
    if (state is BoardListStateContent) {
      if (state.otherBoards.isEmpty) {
        return Constants.noDataPlaceholder;
      }

      bool hasFavorites = state.favoriteBoards.isNotEmpty;
      int totalCount = hasFavorites ? (state.otherBoards.length + state.favoriteBoards.length + 2) : state.otherBoards.length;
      return ScrollablePositionedList.builder(
        itemCount: totalCount,
        itemScrollController: itemScrollController,
        itemBuilder: (context, index) {
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
            onTap = (() => _openBoardDetailPage(state.otherBoards[index].boardId));
          }
          return InkWell(child: child, onTap: onTap);
        },
      );
    } else {
      return Constants.errorPlaceholder;
    }
  }

  void _openBoardDetailPage(String boardId) async {
    await Navigator.pushNamed(
      context,
      Constants.boardDetailRoute,
      arguments: {
        BoardDetailPage.ARG_BOARD_ID: boardId,
      },
    );

    _boardListBloc.add(BoardListEventFetchBoards(false));
  }
}
