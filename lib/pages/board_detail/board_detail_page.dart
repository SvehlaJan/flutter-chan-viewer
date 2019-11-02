import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/thread_detail_page.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:flutter_chan_viewer/view/list_widget_thread.dart';
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
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;
  Completer<void> _refreshCompleter;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _boardDetailBloc = BlocProvider.of<BoardDetailBloc>(context);
    _boardDetailBloc.dispatch(BoardDetailEventAppStarted());
    _boardDetailBloc.dispatch(BoardDetailEventFetchThreads(widget.boardId));
//    _scrollController.addListener(_onScroll);
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
  void dispose() {
    _boardDetailBloc.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  String getPageTitle() => "Board /${widget.boardId}";

  @override
  List<Widget> getPageActions() {
    print('Board detail _isFavorite: $_isFavorite');
    Icon icon = _isFavorite ? Icon(Icons.star) : Icon(Icons.star_border);
    return [IconButton(icon: icon, onPressed: _onFavoriteToggleClick)];
  }

  @override
  Widget buildBody() {
    return BlocBuilder<BoardDetailBloc, BoardDetailState>(
      builder: (context, state) {
        if (state is BoardDetailStateLoading) {
          return Center(
            child: Constants.progressIndicator,
          );
        }
        if (state is BoardDetailStateContent) {
          if (state.threads.isEmpty) {
            return Center(
              child: Text('No threads'),
            );
          }

          _refreshCompleter?.complete();
          _refreshCompleter = Completer();
          return RefreshIndicator(
            onRefresh: () {
              _boardDetailBloc.dispatch(BoardDetailEventFetchThreads(widget.boardId));
              return _refreshCompleter.future;
            },
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  child: ThreadListWidget(state.threads[index]),
                  onTap: () => _openThreadDetailPage(widget.boardId, state.threads[index].threadId),
                );
              },
              itemCount: state.threads.length,
              controller: _scrollController,
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

//  void _onScroll() {
//    final maxScroll = _scrollController.position.maxScrollExtent;
//    final currentScroll = _scrollController.position.pixels;
//    if (maxScroll - currentScroll <= _scrollThreshold && !_boardDetailBloc.isLazyLoading) {
//      _boardDetailBloc.dispatch(BoardDetailEventFetchThreads(widget.boardId, _boardDetailBloc.lastPage + 1));
//    }
//  }

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
