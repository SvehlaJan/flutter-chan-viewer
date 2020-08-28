import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/archive_list_model.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';

import 'board_archive_event.dart';
import 'board_archive_state.dart';

class BoardArchiveBloc extends Bloc<ChanEvent, ChanState> {
  final ChanRepository _repository = getIt<ChanRepository>();
  final String boardId;
  final int _kLazyLoadingTake = 100;
  int lazyLoadingMax = 0;
  List<int> archiveThreadIds = [];
  List<ArchiveThreadWrapper> archiveThreads = List<ArchiveThreadWrapper>();

  BoardArchiveBloc(this.boardId) : super(ChanStateLoading());

  String searchQuery = "";
  bool _didLoadNotCachedThread = false;

  @override
  Stream<ChanState> mapEventToState(ChanEvent event) async* {
    try {
      if (event is ChanEventFetchData) {
        yield ChanStateLoading();
        ArchiveListModel boardDetailModel = await _repository.fetchRemoteArchiveList(boardId);
        archiveThreadIds = boardDetailModel.threads.reversed.toList();

        add(BoardArchiveEventFetchDetailsLazy());
      } else if (event is BoardArchiveEventFetchDetailsLazy) {
        _didLoadNotCachedThread = false;
        lazyLoadingMax = min(archiveThreads.length + _kLazyLoadingTake, archiveThreadIds.length);
        add(BoardArchiveEventFetchDetail(archiveThreads.length));
      } else if (event is BoardArchiveEventFetchDetail) {
        int threadId = archiveThreadIds[event.index];
        archiveThreads.insert(event.index, ArchiveThreadWrapper(ThreadDetailModel.fromCacheDirective(CacheDirective(boardId, threadId)), true));
        yield BoardArchiveStateContent(List.from(archiveThreads), true);

        try {
          ThreadDetailModel threadDetailModel = await _repository.fetchCachedThreadDetail(boardId, threadId);
          if (threadDetailModel == null) {
            _didLoadNotCachedThread = true;
            threadDetailModel = await _repository.fetchRemoteThreadDetail(boardId, threadId, true);
          }
          archiveThreads[event.index] = ArchiveThreadWrapper(threadDetailModel, false);
        } catch (e) {
          ChanLogger.e("Failed to load archived thread", e);
        }

        if (archiveThreads.length < lazyLoadingMax) {
          yield BoardArchiveStateContent(List.from(archiveThreads), true);
          add(BoardArchiveEventFetchDetail(archiveThreads.length));
        } else if (!_didLoadNotCachedThread && isMoreThreadsAvailable()) {
          // if only cached threads were loaded, we want to continue with next batch right away
          add(BoardArchiveEventFetchDetailsLazy());
        } else {
          yield BoardArchiveStateContent(List.from(archiveThreads), false);
        }
      } else if (event is ChanEventSearch) {
        searchQuery = event.query;
        List<ArchiveThreadWrapper> filteredThreads = archiveThreads.where((thread) => _matchesQuery(thread.threadDetailModel.thread, searchQuery)).toList();
        yield BoardArchiveStateContent(List.from(filteredThreads), true);
      }
    } catch (e, stackTrace) {
      ChanLogger.e("Event error!", e, stackTrace);
      yield ChanStateError(e.toString());
    }
  }

  bool isMoreThreadsAvailable() => archiveThreads.length < archiveThreadIds.length;

  void fetchNextDetails() {
    lazyLoadingMax = min(archiveThreads.length + _kLazyLoadingTake, archiveThreadIds.length);
    add(BoardArchiveEventFetchDetailsLazy());
  }

  bool _matchesQuery(ThreadItem thread, String query) {
    return thread.subtitle?.toLowerCase()?.contains(query.toLowerCase()) ?? thread.content?.toLowerCase()?.contains(query.toLowerCase()) ?? false;
  }
}
