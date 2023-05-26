import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/helper/chan_board_item_wrapper.dart';
import 'package:flutter_chan_viewer/models/ui/board_item_vo.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/board_detail/board_detail_page.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/navigation_helper.dart';
import 'package:flutter_chan_viewer/view/list_widget_board.dart';

import 'bloc/board_list_bloc.dart';
import 'bloc/board_list_state.dart';

class BoardListPage extends StatefulWidget {
  @override
  _BoardListPageState createState() => _BoardListPageState();
}

class _BoardListPageState extends BasePageState<BoardListPage> {
  static const String KEY_LIST = "_BoardListPageState.KEY_LIST";

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<BoardListBloc>(context);
    bloc.add(ChanEventInitBloc());
  }

  @override
  String getPageTitle() => "Boards";

  List<PageAction> getPageActions(BuildContext context, ChanState state) {
    bool showSearchButton = state is ChanStateContent && !state.showSearchBar;
    return [
      if (showSearchButton) PageAction("Search", Icons.search, _onSearchClick),
      PageAction("Refresh", Icons.refresh, _onRefreshClick),
    ];
  }

  void _onSearchClick() => startSearch();

  void _onRefreshClick() => bloc.add(ChanEventFetchData());

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoardListBloc, ChanState>(
      bloc: bloc as BoardListBloc?,
      builder: (context, state) => buildScaffold(
        context,
        buildBody(context, state, ((board) => _openBoardDetailPage(board!))),
        pageActions: getPageActions(context, state),
        showSearchBar: state.showSearchBar,
      ),
    );
  }

  Widget buildBody(BuildContext context, ChanState state, Function(BoardItemVO?) onItemClicked) {
    if (state is ChanStateLoading) {
      return Constants.centeredProgressIndicator;
    } else if (state is BoardListStateContent) {
      if (state.boards.isEmpty) {
        return Constants.noDataPlaceholder;
      }

      return Stack(
        children: <Widget>[
          Scrollbar(child: _buildListView(context, state, onItemClicked)),
          if (state.showLazyLoading) LinearProgressIndicator()
        ],
      );
    } else {
      return BasePageState.buildErrorScreen(context, (state as ChanStateError).message);
    }
  }

  Widget _buildListView(BuildContext context, BoardListStateContent state, Function(BoardItemVO?) onItemClicked) {
    return Scrollbar(
      child: ListView.builder(
        key: PageStorageKey<String>(KEY_LIST),
        itemCount: state.boards.length,
        itemBuilder: (context, index) {
          ChanBoardItemWrapper item = state.boards[index];
          if (item.isHeader) {
            return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(item.headerTitle!, style: Theme.of(context).textTheme.subtitle1));
          } else {
            return InkWell(
                child: BoardListWidget(board: item.chanBoard!), onTap: (() => onItemClicked(item.chanBoard)));
          }
        },
      ),
    );
  }

  void _openBoardDetailPage(BoardItemVO board) async {
    await Navigator.of(context).push(NavigationHelper.getRoute(
      Constants.boardDetailRoute,
      {
        BoardDetailPage.ARG_BOARD_ID: board.boardId,
      },
    )!);

    bloc.add(ChanEventFetchData());
  }
}
