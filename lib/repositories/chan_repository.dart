import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter_chan_viewer/api/chan_api_provider.dart';
import 'package:flutter_chan_viewer/models/board_detail_model.dart';
import 'package:flutter_chan_viewer/models/board_list_model.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/utils/chan_cache.dart';
import 'package:flutter_chan_viewer/utils/network_image/cache_directive.dart';
import 'package:flutter_chan_viewer/utils/network_image/disk_cache.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChanRepository {
  static final ChanRepository _repo = new ChanRepository._internal();
  static bool _initialized = false;
  static const int CACHE_MAX_SIZE = 10;

  DiskCache _diskCache;
  ChanCache _chanCache;
  ChanApiProvider _chanApiProvider;
  SharedPreferences _prefs;

  Database _db;
  StoreRef<String, Map<String, dynamic>> _favoriteThreadsStore;
  StoreRef<String, Map<String, dynamic>> _boardsStore;

  BoardListModel boardListMemoryCache;
  final Map<String, BoardDetailModel> boardDetailMemoryCache = HashMap();
  final Map<String, ThreadDetailModel> threadDetailMemoryCache = HashMap();
//  final Set<String> favoriteThreadsCache = Set();

  static ChanRepository getSync() {
    if (!_initialized) throw Exception("Repository must be initialized at first!");
    return _repo;
  }

  static Future<ChanRepository> initAndGet() async {
    if (_initialized) return _repo;

    _repo._diskCache = DiskCache();
    _repo._chanCache = ChanCache.get();
    _repo._chanApiProvider = ChanApiProvider();
    _repo._prefs = await SharedPreferences.getInstance();

    var dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    _repo._db = await databaseFactoryIo.openDatabase(join(dir.path, "chan.db"), version: 1);
    _repo._favoriteThreadsStore = stringMapStoreFactory.store("favorites");
    _repo._boardsStore = stringMapStoreFactory.store("boards");

    HashMap<String, List<ThreadDetailModel>> favoriteThreadsMap = await _repo.getFavoriteThreads();
    List<ThreadDetailModel> favoriteThreadsList = favoriteThreadsMap.values.expand((list) => list).toList();
    for (ThreadDetailModel thread in favoriteThreadsList) {
      _repo.threadDetailMemoryCache[thread.cacheKey] = thread;
    }

    _initialized = true;
    return _repo;
  }

  ChanRepository._internal() {
    // initialization code
  }

  Future<BoardListModel> fetchBoardList(bool forceFetch) async {
    if (!forceFetch) {
      if (boardListMemoryCache != null) {
        return boardListMemoryCache;
      } else if (await _boardsStore.count(_db) > 0) {
        try {
          List<ChanBoard> boards = [];
          var records = await _boardsStore.find(_db);
          records.forEach((record) {
            ChanBoard thread = ChanBoard.fromMappedJson(record.value);
            boards.add(thread);
          });
          BoardListModel model = BoardListModel(boards);
          boardListMemoryCache = model;
          return model;
        } catch (e) {
          print(e);
        }
      }
    }

    boardListMemoryCache = await _chanApiProvider.fetchBoardList();
    List<Map<String, dynamic>> map = boardListMemoryCache.boards.map((board) => board.toJson()).toList();
    await _boardsStore.drop(_db);
    await _boardsStore.addAll(_db, map);
    return boardListMemoryCache;
  }

  Future<BoardDetailModel> fetchBoardDetail(bool forceFetch, String boardId) async {
    if (!forceFetch) {
      if (boardDetailMemoryCache.containsKey(boardId)) {
        return boardDetailMemoryCache[boardId];
      }
    }

    BoardDetailModel boardDetailModel = await _chanApiProvider.fetchThreadList(boardId);
    boardDetailModel.threads.forEach((thread) async {
      return thread.isFavorite = isThreadFavorite(thread.getCacheDirective());
    });
    boardDetailMemoryCache[boardId] = boardDetailModel;
    return boardDetailMemoryCache[boardId];
  }

  Future<ThreadDetailModel> fetchThreadDetail(bool forceFetch, String boardId, int threadId) async {
    CacheDirective cacheDirective = CacheDirective(boardId, threadId);
    if (!forceFetch) {
      if (threadDetailMemoryCache.containsKey(cacheDirective.getCacheKey())) {
        return threadDetailMemoryCache[cacheDirective.getCacheKey()];
      } else if (isThreadFavorite(cacheDirective)) {
        ThreadDetailModel thread = await _tryToGetCachedThread(cacheDirective);
        if (thread != null) {
          threadDetailMemoryCache[thread.cacheKey] = thread;
          return thread;
        }
      }
    }

    ThreadDetailModel threadDetailModel = await _chanApiProvider.fetchPostList(boardId, threadId);
    threadDetailModel.thread.isFavorite = isThreadFavorite(cacheDirective);
    if (threadDetailModel.thread.isFavorite) {
      addThreadToFavorites(threadDetailModel); // update cached data
    }

    threadDetailMemoryCache[threadDetailModel.cacheKey] = threadDetailModel;
    return threadDetailModel;
  }

  bool isThreadFavorite(CacheDirective cacheDirective) {
    if (threadDetailMemoryCache.containsKey(cacheDirective.getCacheKey())) {
      return threadDetailMemoryCache[cacheDirective.getCacheKey()].thread.isFavorite;
    }
//    return _favoriteThreadsStore.record(cacheDirective.getCacheKey()).exists(_db);
    return false;
  }

  Future<bool> isBoardFavorite(String boardId) async => (_prefs.getStringList(Preferences.KEY_FAVORITE_BOARDS) ?? []).contains(boardId);

  Future<void> addThreadToFavorites(ThreadDetailModel model) async {
    try {
      model.thread.isFavorite = true;
      threadDetailMemoryCache[model.cacheKey] = model;

      await _favoriteThreadsStore.record(model.cacheKey).put(_db, model.toJson());
      await moveMediaToPermanentCache(model);
    } catch (e) {
      print(e);
    }
  }

  Future<void> removeThreadFromFavorites(ThreadDetailModel model) async {
    try {
      model.thread.isFavorite = false;
      threadDetailMemoryCache[model.cacheKey] = model;

      await _favoriteThreadsStore.record(model.cacheKey).delete(_db);
      await _chanCache.deleteCacheFolder(model.thread.getCacheDirective());
    } catch (e) {
      print(e);
    }
  }

  Future<HashMap<String, List<ThreadDetailModel>>> getFavoriteThreads() async {
    HashMap<String, List<ThreadDetailModel>> threadMap = HashMap();

    try {
      var records = await _favoriteThreadsStore.find(_db);
      records.forEach((record) {
        CacheDirective directive = CacheDirective.fromPath(record.key);
        ThreadDetailModel thread = ThreadDetailModel.fromJson(directive.boardId, directive.threadId, record.value);
        threadMap[directive.boardId] ??= new List<ThreadDetailModel>();
        threadMap[directive.boardId].add(thread);
      });
    } catch (e) {
      print(e);
    }

    return threadMap;
  }

  Future<void> moveMediaToPermanentCache(ThreadDetailModel model) async {
    model.mediaPosts.forEach((post) async {
      Uint8List data = await _diskCache.loadByUrl(post.getMediaUrl());
      if (data != null) {
        print("moveMediaToPermanentStorage: moving { post.getMediaUrl(): ${post.getMediaUrl()} }");
        await _chanCache.writeMediaFile(post.getMediaUrl(), post.getCacheDirective(), data);
      }
    });
  }

  Future<Uint8List> getCachedMediaFile(String url, CacheDirective cacheDirective) async {
    Uint8List data;
    String uId = DiskCache.uid(url);
    bool isPermanentStorage = cacheDirective != null && isThreadFavorite(cacheDirective);
    if (isPermanentStorage) {
      data = await ChanCache.get().getMediaFile(uId, cacheDirective);
    } else {
      data = await DiskCache().load(uId);
    }

    print("getCachedMediaFile() { cache hit: ${data != null}, isPermanentStorage: $isPermanentStorage, url: $url, uId: $uId, cacheDirective: $cacheDirective");
    return data;
  }

  Future<void> saveMediaFile(String url, CacheDirective cacheDirective, Uint8List data) async {
    String uId = DiskCache.uid(url);
    bool isPermanentStorage = cacheDirective != null && isThreadFavorite(cacheDirective);
    if (isPermanentStorage) {
      await ChanCache.get().writeMediaFile(uId, cacheDirective, data);
    } else {
      await DiskCache().save(uId, data);
    }
    print("saveMediaFile() { isPermanentStorage: $isPermanentStorage, url: $url, uId: $uId, cacheDirective: $cacheDirective");
  }

  Future<void> deleteMediaFile(String url, CacheDirective cacheDirective) async {
    String uId = DiskCache.uid(url);
    if (cacheDirective != null) {
      await ChanCache.get().deleteMediaFile(uId, cacheDirective);
    }
    await DiskCache().evict(uId);
  }

//  Future<void> downloadMedia(ThreadDetailModel model) async {
//    String path = _chanCache.getFolderPath(model.thread.getCacheDirective());
//    bool dirExists = Directory(path).existsSync();
//    print("downloadMedia { path: $path, dirExists: $dirExists }");
//    final taskId = await FlutterDownloader.enqueue(
//      url: model.thread.getMediaUrl(),
//      savedDir: path,
//      showNotification: true, // show download progress in status bar (for Android)
//    );
//    FlutterDownloader.registerCallback(downloadCallback);
//  }

//  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
//    print("downloadCallback { id: $id, status: $status, progress: $progress }");
//
////    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port');
////    send.send([id, status, progress]);
//  }

  Future<ThreadDetailModel> _tryToGetCachedThread(CacheDirective cacheDirective) async {
    try {
      var record = await _favoriteThreadsStore.record(cacheDirective.getCacheKey()).get(_db);
      return ThreadDetailModel.fromJson(cacheDirective.boardId, cacheDirective.threadId, record);
    } catch (e) {
      print("Exception reading favorite thread: { cacheDirective: $cacheDirective, e: $e }");
    }
    return null;
  }
}
