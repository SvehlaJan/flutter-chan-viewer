import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/archive_list_model.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/pages/board_archive/bloc/board_archive_event.dart';
import 'package:flutter_chan_viewer/pages/board_archive/bloc/board_archive_state.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';
import 'package:flutter_chan_viewer/utils/extensions.dart';

class BoardArchiveBloc extends Bloc<ChanEvent, ChanState> {
  final ChanRepository _repository = getIt<ChanRepository>();
  final String boardId;
  List<int> archiveThreadIds = [];
  List<ArchiveThreadWrapper> archiveThreads = List<ArchiveThreadWrapper>();
  List<ArchiveThreadWrapper> cachedThreads = List<ArchiveThreadWrapper>();

  BoardArchiveBloc(this.boardId) : super(ChanStateLoading());

  bool showSearch = false;
  String searchQuery = "";

  @override
  Stream<ChanState> mapEventToState(ChanEvent event) async* {
    try {
      if (event is ChanEventFetchData) {
        yield ChanStateLoading();
        ArchiveListModel boardDetailModel = await _repository.fetchRemoteArchiveList(boardId);
        archiveThreadIds = boardDetailModel.threads.reversed.toList();
        // List<ThreadItem> cachedThreads = await _repository.getArchivedThreads(boardId);

        add(BoardArchiveEventFetchDetail(archiveThreads.length));
      } else if (event is BoardArchiveEventFetchDetail) {
        int threadId = archiveThreadIds[event.index];
        archiveThreads.insert(event.index, ArchiveThreadWrapper(ThreadDetailModel.fromCacheDirective(CacheDirective(boardId, threadId)), true));
        yield BoardArchiveStateContent(List.from(archiveThreads), true);

        try {
          ThreadDetailModel threadDetailModel = await _repository.fetchCachedThreadDetail(boardId, threadId);
          if (threadDetailModel == null) {
            threadDetailModel = await _repository.fetchRemoteThreadDetail(boardId, threadId, true);
          }
          archiveThreads[event.index] = ArchiveThreadWrapper(threadDetailModel, false);
        } catch (e) {
          ChanLogger.e("Failed to load archived thread", e);
        }

        if (archiveThreads.length < archiveThreadIds.length) {
          yield BoardArchiveStateContent(List.from(archiveThreads), true);
          add(BoardArchiveEventFetchDetail(archiveThreads.length));
        } else {
          yield BoardArchiveStateContent(List.from(archiveThreads), false);
        }
      } else if (event is ChanEventSearch) {
        searchQuery = event.query;
        List<ArchiveThreadWrapper> titleMatchThreads = archiveThreads.where((thread) => (thread.threadDetailModel.thread.subtitle ?? "").containsIgnoreCase(searchQuery)).toList();
        List<ArchiveThreadWrapper> bodyMatchThreads = archiveThreads.where((thread) => (thread.threadDetailModel.thread.content ?? "").containsIgnoreCase(searchQuery)).toList();
        yield BoardArchiveStateContent(titleMatchThreads + bodyMatchThreads, true);
      }
    } catch (e, stackTrace) {
      ChanLogger.e("Event error!", e, stackTrace);
      yield ChanStateError(e.toString());
    }
  }
}
