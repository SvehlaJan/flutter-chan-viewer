import 'dart:async';

import 'package:flutter_chan_viewer/data/local/local_data_source.dart';
import 'package:flutter_chan_viewer/data/remote/remote_data_source.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/archive_list_model.dart';
import 'package:flutter_chan_viewer/models/board_detail_model.dart';
import 'package:flutter_chan_viewer/models/board_list_model.dart';
import 'package:flutter_chan_viewer/models/helper/online_state.dart';
import 'package:flutter_chan_viewer/models/ui/board_item.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/repositories/chan_result.dart';
import 'package:flutter_chan_viewer/utils/log_utils.dart';
import 'package:path_provider/path_provider.dart';

class BoardsRepository {
  final logger = LogUtils.getLogger();

  late RemoteDataSource _chanApiProvider;
  late LocalDataSource _localDataSource;

  Future<void> initializeAsync() async {
    _chanApiProvider = getIt<RemoteDataSource>();
    _localDataSource = getIt<LocalDataSource>();

    var dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
  }

  Future<BoardListModel?> fetchBoardList(bool includeNsfw) async {
    BoardListModel model = await _chanApiProvider.fetchBoardList();
    await _localDataSource.saveBoards(model.boards);
    return model;
  }

  Future<BoardListModel?> fetchCachedBoardList(bool includeNsfw) async {
    try {
      List<BoardItem> boards = await _localDataSource.getBoards(includeNsfw);
      return boards.isNotEmpty ? BoardListModel(boards) : null;
    } catch (e, stackTrace) {
      logger.e("fetchCachedBoardList error", e, stackTrace);
    }

    return null;
  }

  Stream<DataResult<BoardListModel>> fetchAndObserveBoardList(bool includeNsfw) {
    StreamController<DataResult<BoardListModel>> streamController =
        StreamController<DataResult<BoardListModel>>.broadcast();
    _localDataSource.getBoards(includeNsfw).then((localBoards) {
      streamController.add(DataResult.loading(BoardListModel(localBoards)));
      _chanApiProvider.fetchBoardList().then((remoteBoards) async {
        await _localDataSource.saveBoards(remoteBoards.boards);
        streamController.addStream(
            _localDataSource.getBoardsStream(includeNsfw).map((boards) => DataResult.success(BoardListModel(boards))));
      });
    });
    return streamController.stream;
  }

  ///////////////////////////////////////////////////////////////////////////////////////////

  Future<BoardDetailModel?> fetchRemoteBoardDetail(String boardId) async {
    BoardDetailModel boardDetailModel = await _chanApiProvider.fetchThreadList(boardId);

    List<ThreadItem> newThreads = boardDetailModel.threads;
    List<int> newThreadIds = newThreads.map((thread) => thread.threadId).toList();
    await _localDataSource.syncWithNewOnlineThreads(boardId, newThreadIds);
    await _localDataSource.saveThreads(newThreads);

    return boardDetailModel;
  }

  Stream<DataResult<BoardDetailModel>> fetchAndObserveBoardDetail(String boardId) {
    StreamController<DataResult<BoardDetailModel>> streamController =
        StreamController<DataResult<BoardDetailModel>>.broadcast();
    _localDataSource.getThreadsByBoardIdAndOnlineState(boardId, OnlineState.ONLINE).then((localThreads) {
      streamController.add(DataResult.loading(BoardDetailModel.withThreads(localThreads)));
      _chanApiProvider.fetchThreadList(boardId).then((remoteThreads) async {
        await _localDataSource.syncWithNewOnlineThreads(
            boardId, remoteThreads.threads.map((thread) => thread.threadId).toList());
        await _localDataSource.saveThreads(remoteThreads.threads);
        streamController.addStream(_localDataSource
            .getThreadsByBoardIdAndOnlineStateStream(boardId, OnlineState.ONLINE)
            .map((threads) => DataResult.success(BoardDetailModel.withThreads(threads))));
      });
    });
    return streamController.stream;
  }

  Future<ArchiveListModel> fetchRemoteArchiveList(String boardId) async {
    ArchiveListModel archiveList = await _chanApiProvider.fetchArchiveList(boardId);
    await _localDataSource.syncWithNewArchivedThreads(boardId, archiveList.threads);
    return archiveList;
  }

  Future<Map<int?, ThreadItem?>> getArchivedThreadsMap(String boardId) async {
    List<ThreadItem> threads = await _localDataSource.getThreadsByBoardIdAndOnlineState(boardId, OnlineState.ARCHIVED);
    return Map.fromIterable(threads, key: (thread) => thread.threadId, value: (thread) => thread);
  }
}
