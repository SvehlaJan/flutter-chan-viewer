import 'dart:async';
import 'dart:collection';

import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/archive_list_model.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/pages/base/base_bloc.dart';
import 'package:flutter_chan_viewer/pages/board_archive/bloc/board_archive_event.dart';
import 'package:flutter_chan_viewer/pages/board_archive/bloc/board_archive_state.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';
import 'package:flutter_chan_viewer/utils/extensions.dart';

class BoardArchiveBloc extends BaseBloc<ChanEvent, ChanState> {
  final ChanRepository _repository = getIt<ChanRepository>();
  final String boardId;
  List<int> archiveThreadIds = [];
  List<ArchiveThreadWrapper> archiveThreads = List<ArchiveThreadWrapper>();
  Map<int, ThreadItem> cachedThreadsMap = HashMap<int, ThreadItem>();

  BoardArchiveBloc(this.boardId) : super(ChanStateLoading());

  @override
  Stream<ChanState> mapEventToState(ChanEvent event) async* {
    try {
      if (event is ChanEventFetchData) {
        yield ChanStateLoading();
        ArchiveListModel boardDetailModel = await _repository.fetchRemoteArchiveList(boardId);
        archiveThreads.clear();
        archiveThreadIds = boardDetailModel.threads.reversed.toList();
        cachedThreadsMap = await _repository.getArchivedThreadsMap(boardId);

        add(BoardArchiveEventFetchDetail(archiveThreads.length));
      } else if (event is BoardArchiveEventFetchDetail) {
        int threadId = archiveThreadIds[event.index];

        if (cachedThreadsMap.containsKey(threadId)) {
          archiveThreads.insert(event.index, ArchiveThreadWrapper(ThreadDetailModel.fromThreadAndPosts(cachedThreadsMap[threadId], []), false));
        } else {
          archiveThreads.insert(event.index, ArchiveThreadWrapper(ThreadDetailModel.fromCacheDirective(CacheDirective(boardId, threadId)), true));
          yield _buildContentState(true);

          try {
            ThreadDetailModel threadDetailModel = await _repository.fetchCachedThreadDetail(boardId, threadId);
            if (threadDetailModel == null) {
              threadDetailModel = await _repository.fetchRemoteThreadDetail(boardId, threadId, true);
            }
            archiveThreads[event.index] = ArchiveThreadWrapper(threadDetailModel, false);
          } catch (e) {
            ChanLogger.e("Failed to load archived thread", e);
          }
        }

        if (archiveThreads.length < archiveThreadIds.length) {
          yield _buildContentState(true);
          add(BoardArchiveEventFetchDetail(archiveThreads.length));
        } else {
          yield _buildContentState(false);
        }
      } else if (event is ChanEventSearch || event is ChanEventShowSearch || event is ChanEventCloseSearch) {
        super.mapEventToState(event);
        yield _buildContentState(false);
      }
    } catch (e, stackTrace) {
      ChanLogger.e("Event error!", e, stackTrace);
      yield ChanStateError(e.toString());
    }
  }

  BoardArchiveStateContent _buildContentState(bool showLazyLoading) {
    List<ArchiveThreadWrapper> threads;
    if (searchQuery.isNotNullNorEmpty) {
      List<ArchiveThreadWrapper> titleMatchThreads = archiveThreads.where((thread) => (thread.threadDetailModel.thread.subtitle ?? "").containsIgnoreCase(searchQuery)).toList();
      List<ArchiveThreadWrapper> bodyMatchThreads = archiveThreads.where((thread) => (thread.threadDetailModel.thread.content ?? "").containsIgnoreCase(searchQuery)).toList();
      threads = LinkedHashSet<ArchiveThreadWrapper>.from(titleMatchThreads + bodyMatchThreads).toList();
    } else {
      threads = List.from(archiveThreads);
    }
    return BoardArchiveStateContent(threads: threads, showSearchBar: showSearchBar, showLazyLoading: showLazyLoading);
  }
}
