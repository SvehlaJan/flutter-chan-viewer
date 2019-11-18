import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/pages/base/base_page_2.dart';
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
  Completer<void> _refreshCompleter;
  final ItemScrollController itemScrollController = ItemScrollController();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _boardDetailBloc = BlocProvider.of<BoardDetailBloc>(context);
    _boardDetailBloc.add(BoardDetailEventAppStarted());
    _boardDetailBloc.add(BoardDetailEventFetchThreads(widget.boardId));
    _refreshCompleter = Completer<void>();

    SharedPreferences.getInstance().then((prefs) {
      List<String> favoriteBoards = prefs.getStringList(Preferences.KEY_FAVORITE_BOARDS) ?? [];
      bool isFavorite = favoriteBoards.contains(widget.boardId);
      setState(() {
        _isFavorite = isFavorite;
      });
    });
  }

  @override
  String getPageTitle() => "/${widget.boardId}";

  @override
  List<Widget> getPageActions() {
    Icon icon = _isFavorite ? Icon(Icons.star) : Icon(Icons.star_border);
    return [IconButton(icon: icon, onPressed: _onFavoriteToggleClick)];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoardDetailBloc, BoardDetailState>(bloc: _boardDetailBloc, builder: (context, state) => buildPage(buildBody(context, state)));
  }

  Widget buildBody(BuildContext context, BoardDetailState state) {
    if (state is BoardDetailStateLoading) {
      return Constants.centeredProgressIndicator;
    }
    _refreshCompleter?.complete();
    _refreshCompleter = Completer();
    return RefreshIndicator(
        onRefresh: () {
          _boardDetailBloc.add(BoardDetailEventFetchThreads(widget.boardId));
          return _refreshCompleter.future;
        },
        child: Scrollbar(child: _buildContent(state)));
  }

  Widget _buildContent(BoardDetailState state) {
    if (state is BoardDetailStateContent) {
      if (state.threads.isEmpty) {
        return Constants.noDataPlaceholder;
      }

      return ScrollablePositionedList.builder(
        itemCount: state.threads.length,
        itemScrollController: itemScrollController,
        itemBuilder: (context, index) {
          return InkWell(
            child: ThreadListWidget(state.threads[index]),
            onTap: () => _openThreadDetailPage(widget.boardId, state.threads[index].threadId),
          );
        },
      );
    } else {
      return Constants.errorPlaceholder;
    }
  }

  void _openThreadDetailPage(String boardId, int threadId) {
    Navigator.pushNamed(
      context,
      Constants.threadDetailRoute,
      arguments: {
        ThreadDetailPage.ARG_BOARD_ID: boardId,
        ThreadDetailPage.ARG_THREAD_ID: threadId,
      },
    );
  }

  void _onFavoriteToggleClick() {
    bool newState = !_isFavorite;
    SharedPreferences.getInstance().then((prefs) {
      List<String> favoriteBoards = prefs.getStringList(Preferences.KEY_FAVORITE_BOARDS) ?? [];
      favoriteBoards.removeWhere((value) => value == widget.boardId);
      if (newState) {
        favoriteBoards.add(widget.boardId);
      }
      prefs.setStringList(Preferences.KEY_FAVORITE_BOARDS, favoriteBoards);
    });
    setState(() {
      _isFavorite = newState;
    });
  }
}
