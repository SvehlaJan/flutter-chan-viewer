import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_chan_viewer/data/local/local_data_source.dart';
import 'package:flutter_chan_viewer/data/remote/remote_data_source.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/archive_list_model.dart';
import 'package:flutter_chan_viewer/models/board_detail_model.dart';
import 'package:flutter_chan_viewer/models/board_list_model.dart';
import 'package:flutter_chan_viewer/models/local/threads_table.dart';
import 'package:flutter_chan_viewer/models/ui/board_item.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';
import 'package:flutter_chan_viewer/repositories/disk_cache.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stream_transform/stream_transform.dart';

class ChanRepository {
  static final ChanRepository _instance = ChanRepository._internal();
  static bool _initialized = false;
  static const int CACHE_MAX_SIZE = 10;

  DiskCache _diskCache;
  ChanStorage _chanStorage;
  ChanDownloader _chanDownloader;
  RemoteDataSource _chanApiProvider;
  LocalDataSource _localDataSource;

  static Future<ChanRepository> initAndGet() async {
    if (_initialized) return _instance;

    _instance._diskCache = getIt<DiskCache>();
    _instance._chanStorage = await getIt.getAsync<ChanStorage>();
    _instance._chanDownloader = await getIt.getAsync<ChanDownloader>();
    _instance._chanApiProvider = getIt<RemoteDataSource>();
    _instance._localDataSource = getIt<LocalDataSource>();

    var dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);

    _initialized = true;
    return _instance;
  }

  ChanRepository._internal() {
    // initialization code
  }

  bool isMediaDownloaded(PostItem post) => _chanStorage.mediaFileExists(post.getMediaUrl(), post.getCacheDirective());

  Future<BoardListModel> fetchCachedBoardList(bool includeNsfw) async {
    try {
      List<BoardItem> boards = await _localDataSource.getBoards(includeNsfw);
      return boards.isNotEmpty ? BoardListModel(boards) : null;
    } catch (e, stackTrace) {
      ChanLogger.e("fetchCachedBoardList error", e, stackTrace);
    }

    return null;
  }

  Future<BoardListModel> fetchRemoteBoardList() async {
    BoardListModel model = await _chanApiProvider.fetchBoardList();
    await _localDataSource.saveBoards(model.boards);
    return model;
  }

  Future<BoardDetailModel> fetchCachedBoardDetail(String boardId) async {
    List<ThreadItem> threads = await _localDataSource.getThreadsByBoardIdAndOnlineState(boardId, OnlineState.ONLINE);
    return threads.isNotEmpty ? BoardDetailModel.withThreads(threads) : null;
  }

  Future<BoardDetailModel> fetchRemoteBoardDetail(String boardId) async {
    BoardDetailModel boardDetailModel = await _chanApiProvider.fetchThreadList(boardId);
    boardDetailModel.threads.forEach((thread) async {
      // TODO - not necessary?
      thread.setFavorite(await isThreadFavorite(thread.boardId, thread.threadId));
    });
    List<int> threadIds = boardDetailModel.threads.map((thread) => thread.threadId).toList();
    await _localDataSource.syncWithNewOnlineThreads(boardId, threadIds);
    await _localDataSource.saveThreads(boardDetailModel.threads);
    return boardDetailModel;
  }

  Future<ArchiveListModel> fetchRemoteArchiveList(String boardId) async {
    ArchiveListModel archiveList = await _chanApiProvider.fetchArchiveList(boardId);
    await _localDataSource.syncWithNewArchivedThreads(boardId, archiveList.threads);
    return archiveList;
  }

  Future<ThreadDetailModel> fetchCachedThreadDetail(String boardId, int threadId) async {
    ThreadItem thread = await _localDataSource.getThreadById(boardId, threadId);
    if (thread != null) {
      List<PostItem> posts = await _localDataSource.getPostsFromThread(thread);

      if (posts.isNotEmpty) {
        ThreadDetailModel model = ThreadDetailModel.fromThreadAndPosts(thread, posts);
        return model;
      }
    }

    return null;
  }

  Future<List<ThreadDetailModel>> fetchCachedThreadDetails(String boardId, List<int> threadIds) async {
    List<ThreadItem> threads = await _localDataSource.getThreadsByIds(boardId, threadIds);

    List<ThreadDetailModel> models = [];
    for (ThreadItem thread in threads) {
      List<PostItem> posts = await _localDataSource.getPostsFromThread(thread);
      models.add(ThreadDetailModel.fromThreadAndPosts(thread, posts));
    }

    return models;
  }

  Stream<ThreadDetailModel> getThreadDetailStream(String boardId, int threadId) {
    return _localDataSource
        .getThreadByIdStream(boardId, threadId)
        .combineLatest(_localDataSource.getPostsByThreadIdStream(boardId, threadId), (thread, posts) => ThreadDetailModel.fromThreadAndPosts(thread, posts));
  }

  FutureOr<ThreadDetailModel> fetchRemoteThreadDetail(String boardId, int threadId, bool isArchived) async {
    ThreadDetailModel model = await _chanApiProvider.fetchThreadDetail(boardId, threadId, isArchived);
    bool isFavorite = await isThreadFavorite(boardId, threadId);
    model.thread.setFavorite(isFavorite);

    await _localDataSource.saveThread(model.thread);
    await _localDataSource.savePosts(model.posts);

    return model;
  }

  Future<bool> isThreadFavorite(String boardId, int threadId) async {
    ThreadItem thread = await _localDataSource.getThreadById(boardId, threadId);
    return thread?.isFavorite() ?? false;
  }

  bool isBoardFavorite(String boardId) => (Preferences.getStringList(Preferences.KEY_FAVORITE_BOARDS)).contains(boardId);

  Future<void> addThreadToFavorites(ThreadDetailModel model) async {
    model.thread.setFavorite(true);
    await _localDataSource.updateThread(model.thread);

    await moveMediaToPermanentCache(model);
  }

  Future<void> removeThreadFromFavorites(ThreadDetailModel model) async {
    model.thread.setFavorite(false);
    await _localDataSource.updateThread(model.thread);

    await moveMediaToTemporaryCache(model);
    await _chanStorage.deleteCacheFolder(model.thread.getCacheDirective());
  }

  Future<void> downloadAllMedia(ThreadDetailModel model) async {
    _chanDownloader.downloadAllMedia(model);
  }

  Future<List<ThreadDetailModel>> getFavoriteThreads() async {
    List<ThreadItem> threads = await _localDataSource.getFavoriteThreads();
    List<ThreadDetailModel> models = [];
    for (ThreadItem thread in threads) {
      List<PostItem> posts = await _localDataSource.getPostsFromThread(thread);
      models.add(ThreadDetailModel.fromThreadAndPosts(thread, posts));
    }

    return models;
  }

  Future<void> moveMediaToPermanentCache(ThreadDetailModel model) async {
    model.mediaPosts.forEach((post) async {
      Uint8List data = await _diskCache.loadByUrl(post.getMediaUrl());
      if (data != null) {
        await _chanStorage.writeMediaFile(post.getMediaUrl(), post.getCacheDirective(), data);
      }
    });
  }

  Future<void> moveMediaToTemporaryCache(ThreadDetailModel model) async {
    model.mediaPosts.forEach((post) async {
      Uint8List data = await _chanStorage.readMediaFile(post.getMediaUrl(), post.getCacheDirective());
      if (data != null) {
        _diskCache.save(post.getMediaUrl(), data);
      }
    });
  }

  Future<Uint8List> getCachedMediaFile(String url, CacheDirective cacheDirective) async {
    String uId = DiskCache.uid(url);
    Uint8List data;

    if (cacheDirective != null) {
      data = await _chanStorage.readMediaFile(url, cacheDirective);
    }
    if (data == null) {
      data = await DiskCache().load(uId);
    }

//    ChanLogger.d("getCachedMediaFile() { cache hit: ${data != null}, url: $url, uId: $uId, cacheDirective: $cacheDirective");
    return data;
  }

  Future<void> saveMediaFile(String url, CacheDirective cacheDirective, Uint8List data) async {
    String uId = DiskCache.uid(url);
    bool isFavorite = cacheDirective != null ? await isThreadFavorite(cacheDirective.boardId, cacheDirective.threadId) : false;
    bool isPermanentStorage = cacheDirective != null && isFavorite;

    if (isPermanentStorage) {
      await _chanStorage.writeMediaFile(url, cacheDirective, data);
    } else {
      await DiskCache().save(uId, data);
    }
//    ChanLogger.d("saveMediaFile() { isPermanentStorage: $isPermanentStorage, url: $url, uId: $uId, cacheDirective: $cacheDirective");
  }

  Future<void> deleteMediaFile(String url, CacheDirective cacheDirective) async {
    String uId = DiskCache.uid(url);
    if (cacheDirective != null) {
      await _chanStorage.deleteMediaFile(url, cacheDirective);
    }
    await DiskCache().evict(uId);
  }

//  Future<void> downloadMedia(ThreadDetailModel model) async {
//    String path = _chanCache.getFolderPath(model.thread.getCacheDirective());
//    bool dirExists = Directory(path).existsSync();
//    ChanLogger.d("downloadMedia { path: $path, dirExists: $dirExists }");
//    final taskId = await FlutterDownloader.enqueue(
//      url: model.thread.getMediaUrl(),
//      savedDir: path,
//      showNotification: true, // show download progress in status bar (for Android)
//    );
//    FlutterDownloader.registerCallback(downloadCallback);
//  }

//  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
//    ChanLogger.d("downloadCallback { id: $id, status: $status, progress: $progress }");
//
////    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port');
////    send.send([id, status, progress]);
//  }
}
