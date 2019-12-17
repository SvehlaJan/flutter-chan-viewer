import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/models/board_detail_model.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/thread_detail_page.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:flutter_chan_viewer/view/list_widget_thread.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc/board_detail_bloc.dart';
import 'bloc/board_detail_event.dart';
import 'bloc/board_detail_state.dart';

class BoardDetailPage extends BasePage {
  static const String ARG_BOARD_ID = "ChanBoardsPage.ARG_BOARD_ID";

  final String boardId;

  BoardDetailPage(this.boardId);

  @override
  _BoardDetailPageState createState() => _BoardDetailPageState();
}

class _BoardDetailPageState extends BasePageState<BoardDetailPage> {
  BoardDetailBloc _boardDetailBloc;

  @override
  void initState() {
    super.initState();
    _boardDetailBloc = BlocProvider.of<BoardDetailBloc>(context);
    _boardDetailBloc.add(BoardDetailEventFetchThreads(false));
  }

  @override
  String getPageTitle() => "/${widget.boardId}";

  @override
  List<Widget> getPageActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.search),
          onPressed: () async {
            ChanThread thread = await showSearch<ChanThread>(context: context, delegate: CustomSearchDelegate(_boardDetailBloc));
            _boardDetailBloc.searchQuery = '';

            if (thread != null) {
              _openThreadDetailPage(thread);
            }
          }),
      IconButton(icon: _boardDetailBloc.isFavorite ? Icon(Icons.star) : Icon(Icons.star_border), onPressed: _onFavoriteToggleClick),
      IconButton(icon: Icon(Icons.refresh), onPressed: () => _boardDetailBloc.add(BoardDetailEventFetchThreads(true))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoardDetailBloc, BoardDetailState>(
        bloc: _boardDetailBloc, builder: (context, state) => buildPage(context, buildBody(context, state, ((thread) => _openThreadDetailPage(thread)))));
  }

  static Widget buildBody(BuildContext context, BoardDetailState state, Function(ChanThread) onItemClicked) {
    if (state is BoardDetailStateLoading) {
      return Constants.centeredProgressIndicator;
    } else if (state is BoardDetailStateContent) {
      if (state.threads.isEmpty) {
        return Constants.noDataPlaceholder;
      }

      return Scrollbar(
        child: ListView.builder(
          itemCount: state.threads.length,
          itemBuilder: (context, index) {
            return InkWell(
              child: ThreadListWidget(state.threads[index]),
              onTap: () => onItemClicked(state.threads[index]),
            );
          },
        ),
      );
    } else {
      return Constants.errorPlaceholder;
    }
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

  void _onFavoriteToggleClick() {
    _boardDetailBloc.add(BoardDetailEventToggleFavorite());
  }
}

class CustomSearchDelegate extends SearchDelegate<ChanThread> {
  CustomSearchDelegate(this._boardDetailBloc);

  final BoardDetailBloc _boardDetailBloc;

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      textTheme: theme.textTheme.copyWith(
          title: theme.textTheme.title.copyWith(
        color: Colors.white,
      )),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: Theme.of(context).textTheme.title.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) => null;

  @override
  Widget buildLeading(BuildContext context) => IconButton(icon: Icon(Icons.arrow_back), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) {
    _boardDetailBloc.add(BoardDetailEventSearchBoards(query));

    return BlocBuilder<BoardDetailBloc, BoardDetailState>(
        bloc: _boardDetailBloc, builder: (context, state) => _BoardDetailPageState.buildBody(context, state, ((thread) => close(context, thread))));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _boardDetailBloc.add(BoardDetailEventSearchBoards(query));

    return BlocBuilder<BoardDetailBloc, BoardDetailState>(
        bloc: _boardDetailBloc, builder: (context, state) => _BoardDetailPageState.buildBody(context, state, ((thread) => close(context, thread))));
  }
}
