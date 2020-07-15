import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/board_detail_model.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
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

  void _onRefreshClick() => _favoritesBloc.add(ChanEventFetchData());

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, ChanState>(bloc: _favoritesBloc, builder: (context, state) => buildScaffold(context, buildBody(context, state)));
  }

  Widget buildBody(BuildContext context, ChanState state) {
    if (state is ChanStateLoading) {
      return Constants.centeredProgressIndicator;
    } else if (state is FavoritesStateContent) {
      List<ThreadDetailModel> threads = state.threadMap.values.expand((list) => list).toList();

      if (threads.isEmpty) {
        return Constants.noDataPlaceholder;
      }

      return Scrollbar(
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              child: ThreadListWidget(thread: threads[index].thread),
              onTap: () => _openThreadDetailPage(threads[index].thread),
            );
          },
          itemCount: threads.length,
        ),
      );
    } else {
      return Constants.errorPlaceholder;
    }
  }

  void _openThreadDetailPage(ChanThread thread) async {
    await Navigator.of(context).push(
      NavigationHelper.getRoute(
        Constants.threadDetailRoute,
        ThreadDetailPage.createArguments(thread.boardId, thread.threadId),
      ),
    );
    _favoritesBloc.add(ChanEventFetchData());
  }
}
