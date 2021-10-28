import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/board_archive/board_archive_page.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/thread_detail_page.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/navigation_helper.dart';
import 'package:flutter_chan_viewer/view/list_widget_thread.dart';

import 'bloc/board_detail_bloc.dart';
import 'bloc/board_detail_event.dart';
import 'bloc/board_detail_state.dart';

class BoardDetailPage extends StatefulWidget {
  static const String ARG_BOARD_ID = "ChanBoardsPage.ARG_BOARD_ID";

  static Map<String, dynamic> createArguments(final String? boardId) {
    Map<String, dynamic> arguments = {ARG_BOARD_ID: boardId};
    return arguments;
  }

  final String? boardId;

  BoardDetailPage(this.boardId);

  @override
  _BoardDetailPageState createState() => _BoardDetailPageState();
}

class _BoardDetailPageState extends BasePageState<BoardDetailPage> {
  static const String KEY_LIST = "_BoardDetailPageState.KEY_LIST";

  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<BoardDetailBloc>(context);
    bloc.add(ChanEventFetchData());

    _scrollController = ScrollController();
  }

  @override
  String getPageTitle() => "/${widget.boardId}";

  List<PageAction> getPageActions(BuildContext context, ChanState state) {
    bool isFavorite = state is BoardDetailStateContent && state.isFavorite;
    return [
      PageAction("Search", Icons.search, _onSearchClick),
      PageAction("Refresh", Icons.refresh, _onRefreshClick),
      PageAction("Archive", Icons.history, _onArchiveClick),
      isFavorite
          ? PageAction("Unstar", Icons.star, _onFavoriteToggleClick)
          : PageAction("Star", Icons.star_border, _onFavoriteToggleClick),
    ];
  }

  void _onSearchClick() => startSearch();

  void _onRefreshClick() => bloc.add(ChanEventFetchData());

  void _onArchiveClick() async {
    await Navigator.of(context).push(NavigationHelper.getRoute(
      Constants.boardArchiveRoute,
      {
        BoardArchivePage.ARG_BOARD_ID: widget.boardId,
      },
    )!);

    bloc.add(ChanEventFetchData());
  }

  void _onFavoriteToggleClick() => bloc.add(BoardDetailEventToggleFavorite());

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BoardDetailBloc, ChanState>(listener: (context, state) {
      switch (state.event) {
        case ChanSingleEvent.CLOSE_PAGE:
          Navigator.of(context).pop();
          break;
        case ChanSingleEvent.SHOW_OFFLINE:
          showOfflineSnackbar(context);
          break;
        default:
          break;
      }
    }, builder: (context, state) {
      return BlocBuilder<BoardDetailBloc, ChanState>(
          bloc: bloc as BoardDetailBloc?,
          builder: (context, state) {
            return buildScaffold(
              context,
              buildBody(
                  context, state, ((thread) => _openThreadDetailPage(thread))),
              pageActions: getPageActions(context, state),
              showSearchBar: state.showSearchBar,
            );
          });
    });
  }

  Widget buildBody(BuildContext context, ChanState state,
      Function(ThreadItem) onItemClicked) {
    if (state is ChanStateLoading) {
      return Constants.centeredProgressIndicator;
    } else if (state is BoardDetailStateContent) {
      if (state.threads.isEmpty) {
        return Constants.noDataPlaceholder;
      }

      return Stack(
        children: <Widget>[
          _buildListView(context, state, onItemClicked),
          if (state.showLazyLoading) LinearProgressIndicator(),
        ],
      );
    } else {
      return BasePageState.buildErrorScreen(
          context, (state as ChanStateError).message);
    }
  }

  Widget _buildListView(BuildContext context, BoardDetailStateContent state,
      Function(ThreadItem) onItemClicked) {
    return DraggableScrollbar.semicircle(
      controller: _scrollController!,
      child: ListView.builder(
        key: PageStorageKey<String>(KEY_LIST),
        controller: _scrollController,
        itemCount: state.threads.length,
        itemBuilder: (context, index) {
          return InkWell(
            child: ThreadListWidget(thread: state.threads[index]),
            onTap: () => onItemClicked(state.threads[index]),
          );
        },
      ),
    );
  }

  void _openThreadDetailPage(ThreadItem thread) {
    Navigator.of(context).push(
      NavigationHelper.getRoute(
        Constants.threadDetailRoute,
        ThreadDetailPage.createArguments(thread.boardId, thread.threadId),
      )!,
    );
  }
}
