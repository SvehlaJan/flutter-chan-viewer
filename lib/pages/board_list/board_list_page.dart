import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/helper/chan_board_item_wrapper.dart';
import 'package:flutter_chan_viewer/models/ui/board_item.dart';
import 'package:flutter_chan_viewer/utils/navigation_helper.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/board_detail/board_detail_page.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/view/list_widget_board.dart';

import 'bloc/board_list_bloc.dart';
import 'bloc/board_list_state.dart';

class BoardListPage extends StatefulWidget {
  @override
  _BoardListPageState createState() => _BoardListPageState();
}

class _BoardListPageState extends BasePageState<BoardListPage> {
  static const String KEY_LIST = "_BoardListPageState.KEY_LIST";

  BoardListBloc _boardListBloc;

  @override
  void initState() {
    super.initState();
    _boardListBloc = BlocProvider.of<BoardListBloc>(context);
    _boardListBloc.add(ChanEventFetchData());
  }

  @override
  String getPageTitle() => "Boards";

  @override
  List<PageAction> getAppBarActions(BuildContext context) => [
        PageAction("Search", Icons.search, _onSearchClick),
        PageAction("Refresh", Icons.refresh, _onRefreshClick),
      ];

  void _onSearchClick() async {
    BoardItem board = await showSearch<BoardItem>(context: context, delegate: CustomSearchDelegate(_boardListBloc));
    _boardListBloc.searchQuery = '';

    if (board != null) {
      _openBoardDetailPage(board);
    }
  }

  void _onRefreshClick() => _boardListBloc.add(ChanEventFetchData());

  @override
  Widget build(BuildContext context) {
    return buildScaffold(
      context,
      BlocBuilder<BoardListBloc, ChanState>(
        cubit: _boardListBloc,
        builder: (context, state) => buildBody(context, state, ((board) => _openBoardDetailPage(board))),
      ),
    );
  }

  static Widget buildBody(BuildContext context, ChanState state, Function(BoardItem) onItemClicked) {
    if (state is ChanStateLoading) {
      return Constants.centeredProgressIndicator;
    } else if (state is BoardListStateContent) {
      if (state.items.isEmpty) {
        return Constants.noDataPlaceholder;
      }

      return Stack(
        children: <Widget>[Scrollbar(child: _buildListView(context, state, onItemClicked)), if (state.lazyLoading) LinearProgressIndicator()],
      );
    } else {
      return BasePageState.buildErrorScreen(context, (state as ChanStateError)?.message);
    }
  }

  static Widget _buildListView(BuildContext context, BoardListStateContent state, Function(BoardItem) onItemClicked) {
    return Scrollbar(
      child: ListView.builder(
        key: PageStorageKey<String>(KEY_LIST),
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          ChanBoardItemWrapper item = state.items[index];
          if (item.isHeader) {
            return Padding(padding: const EdgeInsets.all(8.0), child: Text(item.headerTitle, style: Theme.of(context).textTheme.subhead));
          } else {
            return InkWell(child: BoardListWidget(board: item.chanBoard), onTap: (() => onItemClicked(item.chanBoard)));
          }
        },
      ),
    );
  }

  void _openBoardDetailPage(BoardItem board) async {
    await Navigator.of(context).push(NavigationHelper.getRoute(
      Constants.boardDetailRoute,
      {
        BoardDetailPage.ARG_BOARD_ID: board.boardId,
      },
    ));

    _boardListBloc.add(ChanEventFetchData());
  }
}

class CustomSearchDelegate extends SearchDelegate<BoardItem> {
  CustomSearchDelegate(this._boardListBloc);

  final BoardListBloc _boardListBloc;

  @override
  ThemeData appBarTheme(BuildContext context) => Constants.searchBarTheme(context);

  @override
  List<Widget> buildActions(BuildContext context) => null;

  @override
  Widget buildLeading(BuildContext context) => IconButton(icon: Icon(Icons.arrow_back), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) {
    _boardListBloc.add(ChanEventSearch(query));

    return BlocBuilder<BoardListBloc, ChanState>(
      cubit: _boardListBloc,
      builder: (context, state) => _BoardListPageState.buildBody(context, state, ((board) => close(context, board))),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _boardListBloc.add(ChanEventSearch(query));

    return BlocBuilder<BoardListBloc, ChanState>(
      cubit: _boardListBloc,
      builder: (context, state) => _BoardListPageState.buildBody(context, state, ((board) => close(context, board))),
    );
  }
}
