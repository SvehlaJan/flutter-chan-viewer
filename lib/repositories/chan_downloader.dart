import 'dart:async';

import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

class ChanDownloader {
  static final ChanDownloader _instance = new ChanDownloader._internal();
  static bool _initialized = false;
  static const int CACHE_MAX_SIZE = 10;

  late ChanStorage _chanStorage;

  static Future<ChanDownloader> initAndGet() async {
    if (_initialized) return _instance;

    await FlutterDownloader.initialize();
//    FlutterDownloader.registerCallback(downloadCallback);
    _instance._chanStorage = await getIt.getAsync<ChanStorage>();

    var dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);

    _initialized = true;
    return _instance;
  }

  ChanDownloader._internal() {
    // initialization code
  }

  Future<void> downloadAllMedia(ThreadDetailModel model) async {
    _chanStorage.createDirectory(model.cacheDirective);
    for (PostItem post in model.allMediaPosts) {
      if (!_chanStorage.mediaFileExists(post.getMediaUrl()!, model.cacheDirective)) {
        _TaskInfo task = _TaskInfo(post);
        _requestDownload(task);
      }
    }
  }

  void _requestDownload(_TaskInfo task) async {
    task.taskId = await FlutterDownloader.enqueue(
        url: task.url!,
        savedDir: task.getCacheDir(_chanStorage),
//        fileName: task.fileName,
        showNotification: true);
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    print('Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
//    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port');
//    send.send([id, status, progress]);
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
  final PostItem post;
  String? taskId;
  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  String? get url => post.getMediaUrl();

  String? get fileName => post.filename;

  String getCacheDir(ChanStorage cache) => cache.getFolderAbsolutePath(post.getCacheDirective());

  _TaskInfo(this.post);
}

class _ItemHolder {
  final String? name;
  final _TaskInfo? task;

  _ItemHolder({this.name, this.task});
}
