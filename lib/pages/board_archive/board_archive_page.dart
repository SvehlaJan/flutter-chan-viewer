import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item_vo.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/board_archive/bloc/board_archive_event.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/thread_detail_page.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/navigation_helper.dart';
import 'package:flutter_chan_viewer/view/list_widget_thread.dart';
import 'package:flutter_chan_viewer/view/list_widget_thread_archive.dart';

import 'bloc/board_archive_bloc.dart';
import 'bloc/board_archive_state.dart';

class BoardArchivePage extends StatefulWidget {
  static const String ARG_BOARD_ID = "ArchiveListPage.ARG_BOARD_ID";

  final String boardId;

  BoardArchivePage(this.boardId);

  @override
  _BoardArchivePageState createState() => _BoardArchivePageState();
}

class _BoardArchivePageState extends BasePageState<BoardArchivePage> {
  late ScrollController _listScrollController;

  @override
  void initState() {
    super.initState();
    _listScrollController = ScrollController();

    bloc = BlocProvider.of<BoardArchiveBloc>(context);
    bloc.add(ChanEventFetchData());
  }

  @override
  String getPageTitle() => "/${widget.boardId} Archive";

  List<PageAction> getPageActions(BuildContext context, BoardArchiveState state) {
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
    return BlocConsumer<BoardArchiveBloc, BoardArchiveState>(listener: (context, state) {
      switch (state.event) {
        case BoardArchiveSingleEventShowOffline _:
          showOfflineSnackbar(context);
          break;
        case BoardArchiveSingleEventNavigateToThread _:
          var event = state.event as BoardArchiveSingleEventNavigateToThread;
          Navigator.of(context).push(NavigationHelper.getRoute(
            Constants.threadDetailRoute,
            ThreadDetailPage.createArguments(event.boardId, event.threadId),
          ));
          break;
        default:
          break;
      }
    }, builder: (context, state) {
      return BlocBuilder<BoardArchiveBloc, BoardArchiveState>(
          bloc: bloc as BoardArchiveBloc?,
          builder: (context, state) {
            return buildScaffold(
              context,
              buildBody(context, state),
              pageActions: getPageActions(context, state),
              showSearchBar: state.showSearchBar,
            );
          });
    });
  }

  Widget buildBody(BuildContext context, BoardArchiveState state) {
    switch (state) {
      case BoardArchiveStateLoading _:
        return Constants.centeredProgressIndicator;
      case BoardArchiveStateContent _:
        return _buildContent(context, state);
      case BoardArchiveStateError _:
        return BasePageState.buildErrorScreen(context, state.message);
      default:
        throw Exception("Unknown state: $state");
    }
  }

  Widget _buildContent(BuildContext context, BoardArchiveStateContent state) {
    return Stack(
      children: [
        Scrollbar(
          controller: _listScrollController,
          child: ListView.builder(
            controller: _listScrollController,
            itemCount: state.threads.length,
            itemBuilder: (context, index) {
              ArchiveThreadWrapper threadWrapper = state.threads[index];
              ThreadItemVO thread = threadWrapper.thread;
              if (state.threads[index].isLoading) {
                return ArchiveThreadListWidget(
                  thread: threadWrapper.thread,
                  isLoading: threadWrapper.isLoading,
                );
              } else {
                return InkWell(
                  child: ThreadListWidget(thread: threadWrapper.thread),
                  onTap: () => bloc.add(BoardArchiveEventOnThreadClicked(thread.threadId)),
                );
              }
            },
          ),
        ),
        if (state.showLazyLoading) LinearProgressIndicator(),
      ],
    );
  }
}
