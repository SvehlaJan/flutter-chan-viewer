import 'dart:collection';
import 'dart:io';

import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/archive_list_model.dart';
import 'package:flutter_chan_viewer/models/helper/online_state.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item_vo.dart';
import 'package:flutter_chan_viewer/pages/base/base_bloc.dart';
import 'package:flutter_chan_viewer/pages/board_archive/bloc/board_archive_event.dart';
import 'package:flutter_chan_viewer/pages/board_archive/bloc/board_archive_state.dart';
import 'package:flutter_chan_viewer/repositories/boards_repository.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/repositories/threads_repository.dart';
import 'package:flutter_chan_viewer/utils/exceptions.dart';
import 'package:flutter_chan_viewer/utils/extensions.dart';
import 'package:flutter_chan_viewer/utils/log_utils.dart';

class BoardArchiveBloc extends BaseBloc<ChanEvent, ChanState> {
  final logger = LogUtils.getLogger();
  final BoardsRepository _boardsRepository = getIt<BoardsRepository>();
  final ThreadsRepository _threadsRepository = getIt<ThreadsRepository>();
  final String boardId;
  List<int> archiveThreadIds = [];
  List<ArchiveThreadWrapper> archiveThreads = <ArchiveThreadWrapper>[];
  Map<int?, ThreadItem?> cachedThreadsMap = HashMap<int, ThreadItem>();

  BoardArchiveBloc(this.boardId) : super(ChanStateLoading()) {
    on<ChanEventFetchData>((event, emit) async {
      emit(ChanStateLoading());
      try {
        ArchiveListModel boardDetailModel = await _boardsRepository.fetchRemoteArchiveList(boardId);
        archiveThreads.clear();
        archiveThreadIds = boardDetailModel.threads.reversed.toList();
        cachedThreadsMap = await _boardsRepository.getArchivedThreadsMap(boardId);

        add(BoardArchiveEventFetchDetail(archiveThreads.length));
      } catch (e) {
        if (e is HttpException || e is SocketException) {
          emit(buildContentState(event: ChanSingleEvent.SHOW_OFFLINE));
        } else {
          rethrow;
        }
      }
    });

    on<BoardArchiveEventFetchDetail>((event, emit) async {
      int? threadId = archiveThreadIds[event.index];

      if (cachedThreadsMap.containsKey(threadId)) {
        int batchInsertIndex = event.index;
        while (cachedThreadsMap.containsKey(threadId)) {
          archiveThreads.add(ArchiveThreadWrapper(cachedThreadsMap[threadId]!.toThreadItemVO(), false));
          batchInsertIndex++;
          threadId = batchInsertIndex < archiveThreadIds.length ? archiveThreadIds[batchInsertIndex] : null;
        }
      } else {
        ThreadItem threadItem = ThreadItem.fromCacheDirective(CacheDirective(boardId, threadId));
        archiveThreads.add(ArchiveThreadWrapper(threadItem.toThreadItemVO(), true));
        emit(buildContentState(lazyLoading: true));

        try {
          ThreadDetailModel? threadDetailModel = await _threadsRepository.fetchCachedThreadDetail(boardId, threadId);
          if (threadDetailModel == null) {
            threadDetailModel = await _threadsRepository.fetchRemoteThreadDetail(boardId, threadId, true);
          } else if (threadDetailModel.thread.onlineStatus != OnlineState.ARCHIVED.index) {
            await _threadsRepository
                .updateThread(threadDetailModel.thread.copyWith(onlineStatus: OnlineState.ARCHIVED.index));
          }
          archiveThreads[archiveThreads.length - 1] =
              ArchiveThreadWrapper(threadDetailModel.thread.toThreadItemVO(), false);
        } catch (e) {
          logger.e("Failed to load archived thread", e);
        }
      }

      if (archiveThreads.length < archiveThreadIds.length) {
        emit(buildContentState(lazyLoading: archiveThreads.length % 2 == 0));
        add(BoardArchiveEventFetchDetail(archiveThreads.length));
      } else {
        emit(buildContentState(lazyLoading: false));
      }
    });
  }

  @override
  BoardArchiveStateContent buildContentState({bool lazyLoading = false, ChanSingleEvent? event}) {
    List<ArchiveThreadWrapper> threads;
    if (searchQuery.isNotNullNorEmpty) {
      List<ArchiveThreadWrapper> titleMatchThreads =
          archiveThreads.where((thread) => (thread.thread.subtitle ?? "").containsIgnoreCase(searchQuery)).toList();
      List<ArchiveThreadWrapper> bodyMatchThreads =
          archiveThreads.where((thread) => (thread.thread.content ?? "").containsIgnoreCase(searchQuery)).toList();
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
