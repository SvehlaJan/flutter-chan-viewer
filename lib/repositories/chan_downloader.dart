import 'dart:async';
import 'dart:collection';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

import 'chan_repository.dart';

class ChanDownloader {
  static final ChanDownloader _instance = new ChanDownloader._internal();
  static bool _initialized = false;
  static const int CACHE_MAX_SIZE = 10;

  late ChanStorage _chanStorage;
  ReceivePort _port = ReceivePort();
  final HashMap<String, _TaskInfo> taskMap = HashMap<String, _TaskInfo>();

  static Future<ChanDownloader> initAndGet() async {
    if (_initialized) return _instance;

    await _instance.initializeAsync();

    _initialized = true;
    return _instance;
  }

  ChanDownloader._internal() {
    // initialization code
  }

  Future<void> initializeAsync() async {
    _instance._chanStorage = await getIt.getAsync<ChanStorage>();

    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      if (status == DownloadTaskStatus.complete && progress == 100) {
        if (taskMap[id] != null && taskMap[id]!.post.isWebm()) {
          ChanRepository.createVideoThumbnail(taskMap[id]!.post);
        }
      }
    });

    await FlutterDownloader.initialize();
    FlutterDownloader.registerCallback(downloadCallback);

    var dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
  }

  Future<void> downloadAllMedia(ThreadDetailModel model) async {
    _chanStorage.createDirectory(model.cacheDirective);

    const _channel = const MethodChannel('vn.hunghd/downloader');
    List<dynamic> result = await _channel.invokeMethod('loadTasks');
    List<DownloadTask> currentTasks = result
        .map((item) => new DownloadTask(
            taskId: item['task_id'] ?? 0,
            status: DownloadTaskStatus(item['status'] ?? 0),
            progress: item['progress'] ?? 0,
            url: item['url'] ?? "",
            filename: item['file_name'] ?? "",
            savedDir: item['saved_dir'] ?? "",
            timeCreated: item['time_created'] ?? 0))
        .toList();
    // List<DownloadTask> currentTasks = await FlutterDownloader.loadTasks() ?? [];

    for (PostItem post in model.allMediaPosts) {
      bool fileExists = _chanStorage.mediaFileExists(post.getMediaUrl()!, model.cacheDirective);
      DownloadTask? existingTask;
      try {
        existingTask = currentTasks.firstWhere((element) => element.url == post.getMediaUrl2());
      } catch (e) {
        existingTask = null;
      }

      if (existingTask == null) {
        await _requestDownload(_TaskInfo(post));
        continue;
        // await Future.delayed(Duration(microseconds: 200));
      }
      if ([DownloadTaskStatus.enqueued, DownloadTaskStatus.running].contains(existingTask.status)) {
        print("Url is already enqueued to download. Skipping.");
        continue;
      }
      if (existingTask.status == DownloadTaskStatus.complete) {
        if (fileExists) {
          continue;
        } else {
          await _requestDownload(_TaskInfo(post));
          // await Future.delayed(Duration(microseconds: 200));
        }
      }
    }
  }

  Future<void> _requestDownload(_TaskInfo task) async {
    task.taskId = await FlutterDownloader.enqueue(
      url: task.url!,
      savedDir: task.getCacheDir(_chanStorage),
      showNotification: false,
      openFileFromNotification: false,
    );
    if (task.taskId != null) {
      taskMap[task.taskId!] = task;
    }
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    print('Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');

    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  Future<Null> cancelAllDownloads() async => FlutterDownloader.cancelAll();
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
