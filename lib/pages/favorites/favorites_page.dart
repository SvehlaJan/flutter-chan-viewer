import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/utils/navigation_helper.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/thread_detail_page.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/view/list_widget_thread.dart';

import 'bloc/favorites_bloc.dart';
import 'bloc/favorites_state.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends BasePageState<FavoritesPage> {
  static const String KEY_LIST = "_FavoritesPageState.KEY_LIST";
  FavoritesBloc _favoritesBloc;

  @override
  void initState() {
    super.initState();
    _favoritesBloc = BlocProvider.of<FavoritesBloc>(context);
    _favoritesBloc.add(ChanEventFetchData());
  }

  @override
  String getPageTitle() => "Favorites";

  @override
  List<AppBarAction> getAppBarActions(BuildContext context) => [AppBarAction("Refresh", Icons.refresh, _onRefreshClick)];

  void _onRefreshClick() => _favoritesBloc.add(ChanEventFetchData(forceRefresh: true));

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, ChanState>(
      cubit: _favoritesBloc,
      builder: (context, state) => buildScaffold(context, buildBody(context, state)),
    );
  }

  Widget buildBody(BuildContext context, ChanState state) {
    if (state is ChanStateLoading) {
      return Constants.centeredProgressIndicator;
    } else if (state is FavoritesStateContent) {
      if (state.items.isEmpty) {
        return Constants.noDataPlaceholder;
      }

      return Scrollbar(
        child: ListView.builder(
          key: PageStorageKey<String>(KEY_LIST),
          itemBuilder: (BuildContext context, int index) {
            FavoritesItemWrapper item = state.items[index];
            if (item.isHeader) {
              return Padding(padding: const EdgeInsets.all(8.0), child: Text(item.headerTitle, style: Theme.of(context).textTheme.subhead));
            } else {
              return InkWell(
                child: ThreadListWidget(
                  thread: item.thread.threadDetailModel.thread,
                  showProgress: item.thread.isLoading,
                  newReplies: item.thread.newReplies,
                ),
                onTap: () => _openThreadDetailPage(item.thread),
              );
            }
          },
          itemCount: state.items.length,
        ),
      );
    } else {
      return BasePageState.buildErrorScreen(context, (state as ChanStateError)?.message);
    }
  }

  void _openThreadDetailPage(FavoritesThreadWrapper threadWrapper) async {
    _favoritesBloc.add(ChanEventFetchData());
    ThreadItem thread = threadWrapper.threadDetailModel.thread;
    await Navigator.of(context).push(
      NavigationHelper.getRoute(
        Constants.threadDetailRoute,
        ThreadDetailPage.createArguments(thread.boardId, thread.threadId),
      ),
    );
    _favoritesBloc.add(ChanEventFetchData());
  }
}
