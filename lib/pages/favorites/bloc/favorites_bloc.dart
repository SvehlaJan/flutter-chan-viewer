import 'dart:async';
import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/board_list_model.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';

import 'favorites_state.dart';

class FavoritesBloc extends Bloc<ChanEvent, ChanState> {
  final ChanRepository _repository = getIt<ChanRepository>();

  FavoritesBloc() : super(ChanStateLoading());

  @override
  Stream<ChanState> mapEventToState(ChanEvent event) async* {
    try {
      if (event is ChanEventFetchData) {
        yield ChanStateLoading();

        HashMap<String, List<ThreadDetailModel>> threadMap = await _repository.getFavoriteThreads();
        bool showSfwOnly = Preferences.getBool(Preferences.KEY_SETTINGS_SHOW_SFW_ONLY, def: true);
        if (showSfwOnly) {
          BoardListModel boardListModel = await _repository.fetchCachedBoardList(true); // TODO - includeNsfw
          threadMap.removeWhere((boardId, threads) {
            bool isSfw = boardListModel.boards.where((board) => board.boardId == boardId).first.workSafe ?? false;
            return !isSfw;
          });
        }
        yield FavoritesStateContent(threadMap);
      }
    } catch (e, stackTrace) {
      ChanLogger.e("Event error!", e, stackTrace);
      yield ChanStateError(e.toString());
    }
  }
}
