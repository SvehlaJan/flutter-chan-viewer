import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/board_detail_model.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/pages/board_detail/bloc/board_detail_event.dart';
import 'package:flutter_chan_viewer/pages/board_detail/bloc/board_detail_state.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';
import 'package:flutter_chan_viewer/utils/extensions.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';

class BoardDetailBloc extends Bloc<ChanEvent, ChanState> {
  final ChanRepository _repository = getIt<ChanRepository>();

  BoardDetailBloc(this.boardId) : super(ChanStateLoading());

  final String boardId;
  bool isFavorite = false;
  String searchQuery = "";

  @override
  Stream<ChanState> mapEventToState(ChanEvent event) async* {
    try {
      if (event is ChanEventFetchData) {
        yield ChanStateLoading();
        List<String> favoriteBoards = Preferences.getStringList(Preferences.KEY_FAVORITE_BOARDS);
        isFavorite = favoriteBoards.contains(boardId);

        BoardDetailModel boardDetailModel = await _repository.fetchCachedBoardDetail(boardId);
        if (boardDetailModel != null) {
          List<ThreadItem> titleMatchThreads = boardDetailModel.threads.where((thread) => (thread.subtitle ?? "").containsIgnoreCase(searchQuery)).toList();
          List<ThreadItem> bodyMatchThreads = boardDetailModel.threads.where((thread) => (thread.content ?? "").containsIgnoreCase(searchQuery)).toList();
          yield BoardDetailStateContent(titleMatchThreads + bodyMatchThreads, true, isFavorite);
        }

        boardDetailModel = await _repository.fetchRemoteBoardDetail(boardId);
        List<ThreadItem> titleMatchThreads = boardDetailModel.threads.where((thread) => (thread.subtitle ?? "").containsIgnoreCase(searchQuery)).toList();
        List<ThreadItem> bodyMatchThreads = boardDetailModel.threads.where((thread) => (thread.content ?? "").containsIgnoreCase(searchQuery)).toList();
        yield BoardDetailStateContent(titleMatchThreads + bodyMatchThreads, false, isFavorite);
      } else if (event is ChanEventSearch) {
        searchQuery = event.query;
        add(ChanEventFetchData());
      } else if (event is BoardDetailEventToggleFavorite) {
        isFavorite = !isFavorite;
        List<String> favoriteBoards = Preferences.getStringList(Preferences.KEY_FAVORITE_BOARDS);
        favoriteBoards.removeWhere((value) => value == boardId);
        if (isFavorite) {
          favoriteBoards.add(boardId);
        }
        Preferences.setStringList(Preferences.KEY_FAVORITE_BOARDS, favoriteBoards);
        add(ChanEventFetchData());
      }
    } catch (e, stackTrace) {
      ChanLogger.e("Event error!", e, stackTrace);
      yield ChanStateError(e.toString());
    }
  }
}
