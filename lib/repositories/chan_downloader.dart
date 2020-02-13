import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_chan_viewer/models/chan_post.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/network_image/disk_cache.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class ChanDownloader {
  static final ChanDownloader _instance = new ChanDownloader._internal();
  static bool _initialized = false;
  static const int CACHE_MAX_SIZE = 10;

  ChanStorage _chanStorage;
  Database _db;

  static ChanDownloader getSync() {
    if (!_initialized) throw Exception("Repository must be initialized at first!");
    return _instance;
  }

  static Future<ChanDownloader> initAndGet() async {
    if (_initialized) return _instance;

    WidgetsFlutterBinding.ensureInitialized();
    await FlutterDownloader.initialize();
//    FlutterDownloader.registerCallback(downloadCallback);
    _instance._chanStorage = await ChanStorage.initAndGet();

    var dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    _instance._db = await databaseFactoryIo.openDatabase(join(dir.path, "chan.db"), version: 1);

    _initialized = true;
    return _instance;
  }

  ChanDownloader._internal() {
    // initialization code
  }

  Future<void> downloadAllMedia(ThreadDetailModel model) async {
    _chanStorage.createDirectory(model.cacheDirective);
    for (ChanPost post in model.mediaPosts) {
      if (!_chanStorage.mediaFileExists(post.getMediaUrl(), model.cacheDirective)) {
        _TaskInfo task = _TaskInfo(post);
        _requestDownload(task);
      }
    }
  }

  void _requestDownload(_TaskInfo task) async {
    task.taskId = await FlutterDownloader.enqueue(
        url: task.url,
        savedDir: task.getCacheDir(_chanStorage),
//        fileName: task.fileName,
        showNotification: true);
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    print('Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
//    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port');
//    send.send([id, status, progress]);
  }

  Future<Null> deleteMediaFile(String url, CacheDirective cacheDirective) async {
    String uId = DiskCache.uid(url);
    if (cacheDirective != null) {
      await _chanStorage.deleteMediaFile(uId, cacheDirective);
    }
    await DiskCache().evict(uId);
  }

  Future<Null> cancelAllDownloads() async => FlutterDownloader.cancelAll();

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
}

class _TaskInfo {
  final ChanPost post;
  String taskId;
  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  String get url => post.getMediaUrl();

  String get fileName => post.filename;

  String getCacheDir(ChanStorage cache) => cache.getFolderAbsolutePath(post.getCacheDirective());

  _TaskInfo(this.post);
}

class _ItemHolder {
  final String name;
  final _TaskInfo task;

  _ItemHolder({this.name, this.task});
}
