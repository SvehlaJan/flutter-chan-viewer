import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_chan_viewer/api/chan_api_provider.dart';
import 'package:flutter_chan_viewer/models/board_list_model.dart';
import 'package:flutter_chan_viewer/models/board_detail_model.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/utils/chan_cache.dart';
import 'package:flutter_chan_viewer/utils/network_image/cache_directive.dart';
import 'package:flutter_chan_viewer/utils/network_image/disk_cache.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChanRepository {
  static final ChanRepository _repo = new ChanRepository._internal();
  static bool _initialized = false;
  static const int CACHE_MAX_SIZE = 10;

  DiskCache _diskCache;
  ChanCache _chanCache;
  ChanApiProvider _chanApiProvider;

  BoardListModel boardListMemoryCache;
  final Map<String, BoardDetailModel> boardDetailMemoryCache = HashMap();
  final Map<int, ThreadDetailModel> threadDetailMemoryCache = HashMap();

  static ChanRepository get() {
    if (!_initialized) throw Exception("Repository must be initialized at first!");
    return _repo;
  }

  static Future<void> init() async {
    if (_initialized) return;
    
//    await FlutterDownloader.initialize();
    _repo._diskCache = DiskCache();
    _repo._chanCache = ChanCache.get();
    _repo._chanApiProvider = ChanApiProvider();
    
    _initialized = true;
  }

  ChanRepository._internal() {
    // initialization code
  }

  Future<BoardListModel> fetchBoardList(bool forceFetch) async {
    if (!forceFetch && boardListMemoryCache != null) {
      return boardListMemoryCache;
    }

    boardListMemoryCache = await _chanApiProvider.fetchBoardList();
    return boardListMemoryCache;
  }

  Future<BoardDetailModel> fetchBoardDetail(bool forceFetch, String boardId) async {
    if (!forceFetch && boardDetailMemoryCache.containsKey(boardId)) {
      return boardDetailMemoryCache[boardId];
    }

    boardDetailMemoryCache[boardId] = await _chanApiProvider.fetchThreadList(boardId);
    return boardDetailMemoryCache[boardId];
  }

  Future<ThreadDetailModel> fetchThreadDetail(bool forceFetch, String boardId, int threadId) async {
    if (!forceFetch) {
      if (threadDetailMemoryCache.containsKey(threadId)) {
        return threadDetailMemoryCache[threadId];
      } else if (await isThreadFavorite(threadId)) {
        ThreadDetailModel thread = await _tryToGetCachedThread(boardId, threadId.toString());
        if (thread != null) {
          threadDetailMemoryCache[threadId] = thread;
          return threadDetailMemoryCache[threadId];
        }
      }
    }

    threadDetailMemoryCache[threadId] = await _chanApiProvider.fetchPostList(boardId, threadId);
    if (await isThreadFavorite(threadId)) {
      addThreadToFavorites(threadDetailMemoryCache[threadId]);
    }
    return threadDetailMemoryCache[threadId];
  }

  Future<bool> isThreadFavorite(int threadId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFavorite = (prefs.getStringList(Preferences.KEY_FAVORITE_THREADS) ?? []).contains(threadId.toString());
    return isFavorite;
  }

  Future<void> addThreadToFavorites(ThreadDetailModel model) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteThreads = prefs.getStringList(Preferences.KEY_FAVORITE_THREADS) ?? [];
    favoriteThreads.removeWhere((value) => value == model.thread.threadId.toString());
    favoriteThreads.add(model.thread.threadId.toString());
    prefs.setStringList(Preferences.KEY_FAVORITE_THREADS, favoriteThreads);

    String jsonString = json.encode(model);
    await _chanCache.saveContentString(model.thread.getCacheDirective(), jsonString);
    await moveMediaToPermanentStorage(model);
  }

  Future<void> removeThreadFromFavorites(ThreadDetailModel model) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteThreads = prefs.getStringList(Preferences.KEY_FAVORITE_THREADS) ?? [];
    favoriteThreads.removeWhere((value) => value == model.thread.threadId.toString());
    favoriteThreads.add(model.thread.threadId.toString());
    prefs.setStringList(Preferences.KEY_FAVORITE_THREADS, favoriteThreads);

    await _chanCache.deleteCacheFolder(model.thread.getCacheDirective());
  }

  Future<HashMap<String, List<String>>> getFavoriteThreadNames() async {
    HashMap<String, List<String>> threadMap = await _chanCache.listDirectories();

    return threadMap;
  }

  Future<HashMap<String, List<ThreadDetailModel>>> getFavoriteThreads() async {
    HashMap<String, List<String>> threadPaths = await _chanCache.listDirectories();
    HashMap<String, List<ThreadDetailModel>> threadMap = HashMap();

    threadPaths.forEach((boardId, threadIds) {
      threadMap[boardId] = new List<ThreadDetailModel>();
      threadIds.forEach((threadId) async {
        ThreadDetailModel thread = await _tryToGetCachedThread(boardId, threadId);
        if (thread != null) {
          threadMap[boardId].add(thread);
        }
      });
    });

    return threadMap;
  }

  Future<void> moveMediaToPermanentStorage(ThreadDetailModel model) async {
    model.mediaPosts.forEach((post) async {
      Uint8List data = await _diskCache.loadByUrl(post.getMediaUrl());
      if (data != null) {
        print("moveMediaToPermanentStorage: moving { post.getMediaUrl(): ${post.getMediaUrl()} }");
        await _chanCache.writeMediaFile(post.getMediaUrl(), post.getCacheDirective(), data);
      }
    });
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

  Future<ThreadDetailModel> _tryToGetCachedThread(String boardId, String threadId) async {
    try {
      String threadJson = await _chanCache.readContentString(CacheDirective(boardId, threadId));
      if (threadJson != null) {
        ThreadDetailModel thread = ThreadDetailModel.fromJson(boardId, int.parse(threadId), json.decode(threadJson));
        return thread;
      }
    } catch (e) {
      print("Exception reading favorite thread: { boardId: $boardId, threadId: $threadId, e: $e }");
    }
    return null;
  }
}
