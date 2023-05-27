import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item_vo.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
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
  ScrollController? _listScrollController;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<BoardArchiveBloc>(context);
    bloc.add(ChanEventFetchData());

    _listScrollController = ScrollController();
  }

  @override
  String getPageTitle() => "/${widget.boardId} Archive";

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
    return BlocConsumer<BoardArchiveBloc, ChanState>(listener: (context, state) {
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
      return BlocBuilder<BoardArchiveBloc, ChanState>(
          bloc: bloc as BoardArchiveBloc?,
          builder: (context, state) {
            return buildScaffold(
              context,
              buildBody(context, state, ((thread) => _openThreadDetailPage(thread))),
              pageActions: getPageActions(context, state),
              showSearchBar: state.showSearchBar,
            );
          });
    });
  }

  Widget buildBody(BuildContext context, ChanState state, Function(ThreadItemVO) onItemClicked) {
    if (state is ChanStateLoading) {
      return Constants.centeredProgressIndicator;
    } else if (state is BoardArchiveStateContent) {
      if (state.threads.isEmpty) {
        return Constants.noDataPlaceholder;
      }

      return Stack(
        children: [
          Scrollbar(
            controller: _listScrollController!,
            child: ListView.builder(
              controller: _listScrollController,
              itemCount: state.threads.length,
              itemBuilder: (context, index) {
                ArchiveThreadWrapper threadWrapper = state.threads[index];
                if (state.threads[index].isLoading) {
                  return ArchiveThreadListWidget(
                    thread: threadWrapper.thread,
                    isLoading: threadWrapper.isLoading,
                  );
                } else {
                  return InkWell(
                    child: ThreadListWidget(thread: threadWrapper.thread),
                    onTap: () => onItemClicked(threadWrapper.thread),
                  );
                }
              },
            ),
          ),
          if (state.showLazyLoading) LinearProgressIndicator(),
        ],
      );
    } else {
      return BasePageState.buildErrorScreen(context, (state as ChanStateError).message);
    }
  }

  void _openThreadDetailPage(ThreadItemVO thread) {
    Navigator.of(context).push(
      NavigationHelper.getRoute(
        Constants.threadDetailRoute,
        ThreadDetailPage.createArguments(widget.boardId, thread.threadId),
      ),
    );
  }
}
