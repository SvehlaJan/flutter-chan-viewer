import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/thread_detail_page.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/navigation_helper.dart';
import 'package:flutter_chan_viewer/view/list_widget_thread.dart';
import 'package:flutter_chan_viewer/view/list_widget_thread_custom.dart';

import 'bloc/favorites_bloc.dart';
import 'bloc/favorites_state.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends BasePageState<FavoritesPage> {
  static const String KEY_LIST = "_FavoritesPageState.KEY_LIST";

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<FavoritesBloc>(context);
    bloc.add(ChanEventFetchData());
  }

  @override
  String getPageTitle() => "Favorites";

  List<PageAction> getPageActions(BuildContext context) => [
        PageAction("Search", Icons.search, _onSearchClick),
        PageAction("Refresh", Icons.refresh, _onRefreshClick),
      ];

  void _onSearchClick() => startSearch();

  void _onRefreshClick() => bloc.add(ChanEventFetchData(forceRefresh: true));

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, ChanState>(
      bloc: bloc as FavoritesBloc?,
      builder: (context, state) {
        return buildScaffold(
          context,
          buildBody(context, state),
          pageActions: getPageActions(context),
          showSearchBar: state.showSearchBar,
        );
      },
    );
  }

  Widget buildBody(BuildContext context, ChanState state) {
    if (state is ChanStateLoading) {
      return Constants.centeredProgressIndicator;
    } else if (state is FavoritesStateContent) {
      if (state.threads.isEmpty) {
        return Constants.noDataPlaceholder;
      }

      return Stack(
        children: [
          Scrollbar(
            child: ListView.builder(
              key: PageStorageKey<String>(KEY_LIST),
              itemBuilder: (BuildContext context, int index) {
                FavoritesItemWrapper item = state.threads[index];
                ThreadItem? thread = item.thread?.threadDetailModel.thread;
                if (item.isHeader || thread == null) {
                  return Padding(padding: const EdgeInsets.all(8.0), child: Text(item.headerTitle!, style: Theme.of(context).textTheme.subhead));
                } else {
                  Widget threadWidget = item.thread?.isCustom ?? false
                      ? CustomThreadListWidget(thread: thread)
                      : ThreadListWidget(thread: thread, showProgress: item.thread?.isLoading ?? false, newReplies: item.thread?.newReplies ?? 0);
                  return InkWell(
                    child: threadWidget,
                    onTap: () => _openThreadDetailPage(item.thread!),
                  );
                }
              },
              itemCount: state.threads.length,
            ),
          ),
          if (state.showLazyLoading) LinearProgressIndicator(),
        ],
      );
    } else {
      return BasePageState.buildErrorScreen(context, (state as ChanStateError).message);
    }
  }

  void _openThreadDetailPage(FavoritesThreadWrapper threadWrapper) async {
    bloc.add(ChanEventFetchData());
    ThreadItem thread = threadWrapper.threadDetailModel.thread;
    await Navigator.of(context).push(
      NavigationHelper.getRoute(
        Constants.threadDetailRoute,
        ThreadDetailPage.createArguments(thread.boardId, thread.threadId),
      )!,
    );
    bloc.add(ChanEventFetchData());
  }
}
