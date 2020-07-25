import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_chan_viewer/api/chan_api_provider.dart';
import 'package:flutter_chan_viewer/data/local/local_data_source.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/archive_list_model.dart';
import 'package:flutter_chan_viewer/models/board_detail_model.dart';
import 'package:flutter_chan_viewer/models/board_list_model.dart';
import 'package:flutter_chan_viewer/models/local/threads_table.dart';
import 'package:flutter_chan_viewer/models/ui/board_item.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';
import 'package:flutter_chan_viewer/repositories/disk_cache.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class ChanRepository {
  static final ChanRepository _instance = ChanRepository._internal();
  static bool _initialized = false;
  static const int CACHE_MAX_SIZE = 10;

  DiskCache _diskCache;
  ChanStorage _chanStorage;
  ChanDownloader _chanDownloader;
  ChanApiProvider _chanApiProvider;
  LocalDataSource _localDataSource;

  Database _db;
  StoreRef<String, Map<String, dynamic>> _favoriteThreadsStore;
  StoreRef<String, Map<String, dynamic>> _allThreadsStore;
  StoreRef<String, Map<String, dynamic>> _boardsStore;

  final Map<String, BoardDetailModel> boardDetailMemoryCache = HashMap();
  final Map<String, ThreadDetailModel> threadDetailMemoryCache = HashMap();

  static Future<ChanRepository> initAndGet() async {
    if (_initialized) return _instance;

    _instance._diskCache = getIt<DiskCache>();
    _instance._chanStorage = await getIt.getAsync<ChanStorage>();
    _instance._chanDownloader = await getIt.getAsync<ChanDownloader>();
    _instance._chanApiProvider = getIt<ChanApiProvider>();
    _instance._localDataSource = getIt<LocalDataSource>();

    var dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    _instance._db = await databaseFactoryIo.openDatabase(join(dir.path, "chan.db"), version: 1);
    _instance._favoriteThreadsStore = stringMapStoreFactory.store("favorites");
    _instance._allThreadsStore = stringMapStoreFactory.store("all_threads");
    _instance._boardsStore = stringMapStoreFactory.store("boards");

    HashMap<String, List<ThreadDetailModel>> favoriteThreadsMap = await _instance.getFavoriteThreads();
    List<ThreadDetailModel> favoriteThreadsList = favoriteThreadsMap.values.expand((list) => list).toList();
    for (ThreadDetailModel thread in favoriteThreadsList) {
      _instance.threadDetailMemoryCache[thread.cacheKey] = thread;
    }

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

    return Future.value(null);
  }

  Future<BoardListModel> fetchRemoteBoardList() async {
    BoardListModel model = await _chanApiProvider.fetchBoardList();
    _localDataSource.saveBoards(model.boards);
    return model;
  }

  Future<BoardDetailModel> fetchCachedBoardDetail(String boardId) async {
    if (boardDetailMemoryCache.containsKey(boardId)) {
      return boardDetailMemoryCache[boardId];
    }

    return Future.value(null);
  }

  Future<BoardDetailModel> fetchRemoteBoardDetail(String boardId) async {
    BoardDetailModel boardDetailModel = await _chanApiProvider.fetchThreadList(boardId);
    boardDetailModel.threads.forEach((thread) async {
      thread.setFavorite(isThreadFavorite(thread.getCacheDirective()));
    });
    boardDetailMemoryCache[boardId] = boardDetailModel;
    return boardDetailMemoryCache[boardId];
  }

  Future<ArchiveListModel> fetchRemoteArchiveList(String boardId) async {
    ArchiveListModel archiveList = await _chanApiProvider.fetchArchiveList(boardId);
    return archiveList;
  }

  Future<ThreadDetailModel> fetchCachedThreadDetail(String boardId, int threadId) async {
    CacheDirective cacheDirective = CacheDirective(boardId, threadId);
    if (threadDetailMemoryCache.containsKey(cacheDirective.getCacheKey())) {
      return threadDetailMemoryCache[cacheDirective.getCacheKey()];
    }

    ThreadDetailModel thread = await _tryToGetCachedThread(cacheDirective);
    if (thread != null) {
      threadDetailMemoryCache[thread.cacheKey] = thread;
      return thread;
    }

    return Future.value(null);
  }

  FutureOr<ThreadDetailModel> fetchRemoteThreadDetail(String boardId, int threadId) async {
    ThreadDetailModel model = await _chanApiProvider.fetchPostList(boardId, threadId);
    bool isFavorite = isThreadFavorite(CacheDirective(boardId, threadId));
    model.thread.setFavorite(isFavorite);

    await saveThreadDetail(model);
    return model;
  }

  FutureOr<void> saveThreadDetail(ThreadDetailModel model) async {
    if (model.thread.isFavorite()) {
      await _favoriteThreadsStore.record(model.cacheKey).put(_db, model.toJson());
    } else {
      await _allThreadsStore.record(model.cacheKey).put(_db, model.toJson());
    }

//    await _localDataSource.savePosts(model.posts);

    threadDetailMemoryCache[model.cacheKey] = model;
  }

  Stream<ThreadDetailModel> listenToLocalThreadDetail(CacheDirective cacheDirective) {
    return _favoriteThreadsStore.record(cacheDirective.getCacheKey()).onSnapshot(_db).asBroadcastStream().transform(StreamTransformer.fromHandlers(handleData: (entries, sink) {
          ThreadDetailModel model = ThreadDetailModel.fromJson(cacheDirective.boardId, cacheDirective.threadId, OnlineState.UNKNOWN, entries.value);
          sink.add(model);
        }, handleError: (error, stacktrace, sink) {
          debugPrint(error);
        }));
  }

  bool isThreadFavorite(CacheDirective cacheDirective) {
    if (threadDetailMemoryCache.containsKey(cacheDirective.getCacheKey())) {
      return threadDetailMemoryCache[cacheDirective.getCacheKey()].thread.isFavorite();
    }
//    return _favoriteThreadsStore.record(cacheDirective.getCacheKey()).exists(_db);
    return false;
  }

  bool isBoardFavorite(String boardId) => (Preferences.getStringList(Preferences.KEY_FAVORITE_BOARDS)).contains(boardId);

  Future<void> addThreadToFavorites(ThreadDetailModel model) async {
    try {
      model.thread.setFavorite(true);
      threadDetailMemoryCache[model.cacheKey] = model;

      await _favoriteThreadsStore.record(model.cacheKey).put(_db, model.toJson());
      await moveMediaToPermanentCache(model);
    } catch (e, stackTrace) {
      ChanLogger.e("addThreadToFavorites error", e, stackTrace);
    }
  }

  Future<void> removeThreadFromFavorites(ThreadDetailModel model) async {
    try {
      model.thread.setFavorite(false);
      threadDetailMemoryCache[model.cacheKey] = model;

      await _favoriteThreadsStore.record(model.cacheKey).delete(_db);
      await moveMediaToTemporaryCache(model);
      await _chanStorage.deleteCacheFolder(model.thread.getCacheDirective());
    } catch (e, stackTrace) {
      ChanLogger.e("removeThreadFromFavorites error", e, stackTrace);
    }
  }

  Future<void> downloadAllMedia(ThreadDetailModel model) async {
    _chanDownloader.downloadAllMedia(model);
  }

  Future<HashMap<String, List<ThreadDetailModel>>> getFavoriteThreads() async {
    HashMap<String, List<ThreadDetailModel>> threadMap = HashMap();

    try {
      var records = await _favoriteThreadsStore.find(_db);
      records.forEach((record) {
        CacheDirective directive = CacheDirective.fromPath(record.key);
        ThreadDetailModel thread = ThreadDetailModel.fromJson(directive.boardId, directive.threadId, OnlineState.UNKNOWN, record.value);
        threadMap[directive.boardId] ??= List<ThreadDetailModel>();
        threadMap[directive.boardId].add(thread);
      });
    } catch (e, stackTrace) {
      ChanLogger.e("getFavoriteThreads error", e, stackTrace);
    }

    return threadMap;
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
    bool isPermanentStorage = cacheDirective != null && isThreadFavorite(cacheDirective);

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

  Future<ThreadDetailModel> _tryToGetCachedThread(CacheDirective cacheDirective) async {
    try {
      var record = await _favoriteThreadsStore.record(cacheDirective.getCacheKey()).get(_db) ?? await _allThreadsStore.record(cacheDirective.getCacheKey()).get(_db);
//      List<PostItem> posts = await _localDataSource.getPostsByThreadId(cacheDirective.threadId, cacheDirective.boardId);
      if (record != null) {
        return ThreadDetailModel.fromJson(cacheDirective.boardId, cacheDirective.threadId, OnlineState.UNKNOWN, record);
      } else {
        return null;
      }
    } catch (e, stackTrace) {
      ChanLogger.e("Exception reading cached thread: { cacheDirective: $cacheDirective }", e, stackTrace);
    }
    return null;
  }
}
