import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item_vo.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/favorites/bloc/favorites_bloc.dart';
import 'package:flutter_chan_viewer/pages/favorites/bloc/favorites_event.dart';
import 'package:flutter_chan_viewer/pages/favorites/bloc/favorites_state.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/thread_detail_page.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/navigation_helper.dart';
import 'package:flutter_chan_viewer/view/list_widget_thread.dart';
import 'package:flutter_chan_viewer/view/list_widget_thread_custom.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends BasePageState<FavoritesPage> {
  static const String KEY_LIST = "_FavoritesPageState.KEY_LIST";
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    bloc = BlocProvider.of<FavoritesBloc>(context);
    bloc.add(ChanEventFetchData());
  }

  @override
  String getPageTitle() => "Favorites";

  List<PageAction> getPageActions(BuildContext context, FavoritesState state) {
    bool showSearchButton = !state.showSearchBar;
    return [
      if (showSearchButton) PageAction("Search", Icons.search, _onSearchClick),
      PageAction("Refresh", Icons.refresh, _onRefreshClick),
    ];
  }

  void _onSearchClick() => startSearch();

  void _onRefreshClick() => bloc.add(ChanEventFetchData(forceRefresh: true));

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FavoritesBloc, FavoritesState>(
      listener: (BuildContext context, state) async {
        switch (state.event) {
          case FavoritesSingleEventNavigateToThread _:
            var event = state.event as FavoritesSingleEventNavigateToThread;
            await Navigator.of(context).push(NavigationHelper.getRoute(
              Constants.threadDetailRoute,
              ThreadDetailPage.createArguments(event.boardId, event.threadId),
            ));
            bloc.add(ChanEventFetchData()); // Refresh data after returning from thread detail
            break;
          default:
            break;
        }
      },
      builder: (BuildContext context, Object? state) {
        return BlocBuilder<FavoritesBloc, FavoritesState>(
          bloc: bloc as FavoritesBloc?,
          builder: (context, state) {
            return buildScaffold(
              context,
              buildBody(context, state),
              pageActions: getPageActions(context, state),
              showSearchBar: state.showSearchBar,
            );
          },
        );
      },
    );
  }

  Widget buildBody(BuildContext context, FavoritesState state) {
    switch (state) {
      case FavoritesStateLoading _:
        return Constants.centeredProgressIndicator;
      case FavoritesStateContent _:
        return _buildContent(context, state);
      case FavoritesStateError _:
        return BasePageState.buildErrorScreen(context, state.message);
      default:
        throw Exception("Unknown state: $state");
    }
  }

  Widget _buildContent(BuildContext context, FavoritesStateContent state) {
    return Stack(
      children: [
        Scrollbar(
          controller: _scrollController,
          child: ListView.builder(
            key: PageStorageKey<String>(KEY_LIST),
            controller: _scrollController,
            itemBuilder: (BuildContext context, int index) {
              FavoritesItemWrapper item = state.threads[index];
              ThreadItemVO? thread = item.thread?.thread;
              if (item.isHeader || thread == null) {
                return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(item.headerTitle!, style: Theme.of(context).textTheme.subtitle1));
              } else {
                Widget threadWidget = item.thread?.isCustom ?? false
                    ? CustomThreadListWidget(thread: thread)
                    : ThreadListWidget(thread: thread, showProgress: item.thread?.isLoading ?? false);
                return InkWell(
                  child: threadWidget,
                  onTap: () => bloc.add(FavoritesEventOnThreadClicked(thread.boardId, thread.threadId)),
                );
              }
            },
            itemCount: state.threads.length,
          ),
        ),
        if (state.showLazyLoading) LinearProgressIndicator(),
      ],
    );
  }
}
