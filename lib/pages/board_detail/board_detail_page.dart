import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/board_detail_model.dart';
import 'package:flutter_chan_viewer/pages/board_archive/board_archive_page.dart';
import 'package:flutter_chan_viewer/utils/navigation_helper.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/thread_detail_page.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/view/list_widget_thread.dart';

import 'bloc/board_detail_bloc.dart';
import 'bloc/board_detail_event.dart';
import 'bloc/board_detail_state.dart';

class BoardDetailPage extends StatefulWidget {
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
    _boardDetailBloc.add(ChanEventFetchData());
  }

  @override
  String getPageTitle() => "/${widget.boardId}";

  @override
  List<AppBarAction> getAppBarActions(BuildContext context) => [
        AppBarAction("Search", Icons.search, _onSearchClick),
        AppBarAction("Refresh", Icons.refresh, _onRefreshClick),
        AppBarAction("Archive", Icons.history, _onArchiveClick),
        _boardDetailBloc.isFavorite ? AppBarAction("Unstar", Icons.star, _onFavoriteToggleClick) : AppBarAction("Star", Icons.star_border, _onFavoriteToggleClick),
      ];

  void _onSearchClick() async {
    ChanThread thread = await showSearch<ChanThread>(context: context, delegate: CustomSearchDelegate(_boardDetailBloc));
    _boardDetailBloc.searchQuery = '';

    if (thread != null) {
      _openThreadDetailPage(thread);
    }
  }

  void _onRefreshClick() => _boardDetailBloc.add(ChanEventFetchData());

  void _onArchiveClick() async {
    await Navigator.of(context).push(NavigationHelper.getRoute(
      Constants.boardArchiveRoute,
      {
        BoardArchivePage.ARG_BOARD_ID: widget.boardId,
      },
    ));

    _boardDetailBloc.add(ChanEventFetchData());
  }

  void _onFavoriteToggleClick() => _boardDetailBloc.add(BoardDetailEventToggleFavorite());

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoardDetailBloc, ChanState>(
        bloc: _boardDetailBloc, builder: (context, state) => buildScaffold(context, buildBody(context, state, ((thread) => _openThreadDetailPage(thread)))));
  }

  static Widget buildBody(BuildContext context, ChanState state, Function(ChanThread) onItemClicked) {
    if (state is ChanStateLoading) {
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
              child: ThreadListWidget(thread: state.threads[index]),
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
    Navigator.of(context).push(
      NavigationHelper.getRoute(
        Constants.threadDetailRoute,
        ThreadDetailPage.createArguments(thread.boardId, thread.threadId),
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate<ChanThread> {
  CustomSearchDelegate(this._boardDetailBloc);

  final BoardDetailBloc _boardDetailBloc;

  @override
  ThemeData appBarTheme(BuildContext context) => Constants.searchBarTheme(context);

  @override
  List<Widget> buildActions(BuildContext context) => null;

  @override
  Widget buildLeading(BuildContext context) => IconButton(icon: Icon(Icons.arrow_back), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) {
    _boardDetailBloc.add(ChanEventSearch(query));

    return BlocBuilder<BoardDetailBloc, ChanState>(
        bloc: _boardDetailBloc, builder: (context, state) => _BoardDetailPageState.buildBody(context, state, ((thread) => close(context, thread))));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _boardDetailBloc.add(ChanEventSearch(query));

    return BlocBuilder<BoardDetailBloc, ChanState>(
        bloc: _boardDetailBloc, builder: (context, state) => _BoardDetailPageState.buildBody(context, state, ((thread) => close(context, thread))));
  }
}
