import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/helper/chan_board_item_wrapper.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/board_detail/board_detail_page.dart';
import 'package:flutter_chan_viewer/pages/board_list/bloc/board_list_event.dart';
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
  late ScrollController _listScrollController;
  static const String KEY_LIST = "_BoardListPageState.KEY_LIST";

  @override
  void initState() {
    super.initState();
    _listScrollController = ScrollController();

    bloc = BlocProvider.of<BoardListBloc>(context);
    bloc.add(ChanEventInitBloc());
  }

  @override
  String getPageTitle() => "Boards";

  List<PageAction> getPageActions(BuildContext context, BoardListState state) {
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
    return BlocConsumer<BoardListBloc, BoardListState>(
      listener: (BuildContext context, state) {
        switch (state.event) {
          case BoardListSingleEventShowOffline _:
            showOfflineSnackbar(context);
            break;
          case BoardListSingleEventNavigateToBoard _:
            var event = state.event as BoardListSingleEventNavigateToBoard;
            Navigator.of(context).push(NavigationHelper.getRoute(
              Constants.boardDetailRoute,
              BoardDetailPage.createArguments(event.boardId),
            ));
        }
      },
      builder: (BuildContext context, Object? state) {
        return BlocBuilder<BoardListBloc, BoardListState>(
          bloc: bloc as BoardListBloc?,
          builder: (context, state) => buildScaffold(
            context,
            buildBody(context, state),
            pageActions: getPageActions(context, state),
            showSearchBar: state.showSearchBar,
          ),
        );
      },
    );
  }

  Widget buildBody(BuildContext context, BoardListState state) {
    switch (state) {
      case BoardListStateLoading _:
        return Constants.centeredProgressIndicator;
      case BoardListStateContent _:
        return Stack(
          children: <Widget>[
            _buildListView(context, state.boards),
            if (state.showLazyLoading) LinearProgressIndicator()
          ],
        );
      case BoardListStateError _:
        return BasePageState.buildErrorScreen(context, state.message);
      default:
        return throw Exception("Unknown state: $state");
    }
  }

  Widget _buildListView(BuildContext context, List<ChanBoardItemWrapper> boards) {
    return Scrollbar(
      controller: _listScrollController,
      child: ListView.builder(
        key: PageStorageKey<String>(KEY_LIST),
        controller: _listScrollController,
        itemCount: boards.length,
        itemBuilder: (context, index) {
          ChanBoardItemWrapper item = boards[index];
          if (item.isHeader) {
            return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(item.headerTitle!, style: Theme.of(context).textTheme.subtitle1));
          } else {
            return InkWell(
              child: BoardListWidget(board: item.chanBoard!),
              onTap: (() => bloc.add(BoardListEventOnItemClicked(item.chanBoard!.boardId))),
            );
          }
        },
      ),
    );
  }
}
