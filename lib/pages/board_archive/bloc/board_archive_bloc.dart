import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/data/remote/app_exception.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/archive_list_model.dart';
import 'package:flutter_chan_viewer/models/local/threads_table.dart';
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
  List<ArchiveThreadWrapper> archiveThreads = <ArchiveThreadWrapper>[];
  Map<int?, ThreadItem?> cachedThreadsMap = HashMap<int, ThreadItem>();

  BoardArchiveBloc(this.boardId) : super(ChanStateLoading());

  @override
  Stream<ChanState> mapEventToState(ChanEvent event) async* {
    try {
      if (event is ChanEventFetchData) {
        yield ChanStateLoading();
        try {
          ArchiveListModel boardDetailModel = await _repository.fetchRemoteArchiveList(boardId);
          archiveThreads.clear();
          archiveThreadIds = boardDetailModel.threads.reversed.toList();
          cachedThreadsMap = await _repository.getArchivedThreadsMap(boardId);

          add(BoardArchiveEventFetchDetail(archiveThreads.length));
        } catch (e, stackTrace) {
          if (e is HttpException || e is SocketException) {
            yield _buildContentState(event: ChanSingleEvent.SHOW_OFFLINE);
          } else {
            rethrow;
          }
        }
      } else if (event is BoardArchiveEventFetchDetail) {
        int? threadId = archiveThreadIds[event.index];

        if (cachedThreadsMap.containsKey(threadId)) {
          int batchInsertIndex = event.index;
          while (cachedThreadsMap.containsKey(threadId)) {
            archiveThreads.add(ArchiveThreadWrapper(ThreadDetailModel.fromThreadAndPosts(cachedThreadsMap[threadId]!, []), false));
            batchInsertIndex++;
            threadId = batchInsertIndex < archiveThreadIds.length ? archiveThreadIds[batchInsertIndex] : null;
          }
        } else {
          archiveThreads.add(ArchiveThreadWrapper(ThreadDetailModel.fromCacheDirective(CacheDirective(boardId, threadId)), true));
          yield _buildContentState(lazyLoading: true);

          try {
            ThreadDetailModel? threadDetailModel = await _repository.fetchCachedThreadDetail(boardId, threadId);
            if (threadDetailModel == null) {
              threadDetailModel = await _repository.fetchRemoteThreadDetail(boardId, threadId, true);
            } else if (threadDetailModel.thread.onlineStatus != OnlineState.ARCHIVED.index) {
              await _repository.updateThread(threadDetailModel.thread.copyWith(onlineStatus: OnlineState.ARCHIVED.index));
            }
            archiveThreads[archiveThreads.length - 1] = ArchiveThreadWrapper(threadDetailModel, false);
          } catch (e) {
            ChanLogger.e("Failed to load archived thread", e);
          }
        }

        if (archiveThreads.length < archiveThreadIds.length) {
          yield _buildContentState(lazyLoading: archiveThreads.length % 2 == 0);
          add(BoardArchiveEventFetchDetail(archiveThreads.length));
        } else {
          yield _buildContentState(lazyLoading: false);
        }
      } else if (event is ChanEventSearch || event is ChanEventShowSearch || event is ChanEventCloseSearch) {
        mapEventDefaults(event);
        yield _buildContentState(lazyLoading: false);
      }
    } catch (e, stackTrace) {
      ChanLogger.e("Event error!", e, stackTrace);
      yield ChanStateError(e.toString());
    }
  }

  BoardArchiveStateContent _buildContentState({bool lazyLoading = false, ChanSingleEvent? event}) {
    List<ArchiveThreadWrapper> threads;
    if (searchQuery.isNotNullNorEmpty) {
      List<ArchiveThreadWrapper> titleMatchThreads =
          archiveThreads.where((thread) => (thread.threadDetailModel.thread.subtitle ?? "").containsIgnoreCase(searchQuery)).toList();
      List<ArchiveThreadWrapper> bodyMatchThreads =
          archiveThreads.where((thread) => (thread.threadDetailModel.thread.content ?? "").containsIgnoreCase(searchQuery)).toList();
      threads = LinkedHashSet<ArchiveThreadWrapper>.from(titleMatchThreads + bodyMatchThreads).toList();
    } else {
      threads = archiveThreads;
    }
    return BoardArchiveStateContent(
      threads: threads,
      showLazyLoading: lazyLoading,
      showSearchBar: showSearchBar,
      event: event,
    );
  }
}
