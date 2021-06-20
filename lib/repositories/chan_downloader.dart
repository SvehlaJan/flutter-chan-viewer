import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

import 'chan_repository.dart';

class ChanDownloader {
  static final ChanDownloader _instance = new ChanDownloader._internal();
  static bool _initialized = false;
  static const int CACHE_MAX_SIZE = 10;

  late ChanStorage _chanStorage;
  ReceivePort _port = ReceivePort();
  static List<_TaskInfo> taskList = [];
  List<DownloadTask> currentTasks = [];

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

    await FlutterDownloader.initialize();
    FlutterDownloader.registerCallback(ChanDownloader.downloadCallback);

    var dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
  }

  Future<void> downloadThreadMedia(ThreadDetailModel model) async {
    _chanStorage.createDirectory(model.cacheDirective);

    // const _channel = const MethodChannel('vn.hunghd/downloader');
    // List<dynamic> result = await _channel.invokeMethod('loadTasks');
    // currentTasks = result
    //     .map((item) => new DownloadTask(
    //         taskId: item['task_id'] ?? 0,
    //         status: DownloadTaskStatus(item['status'] ?? 0),
    //         progress: item['progress'] ?? 0,
    //         url: item['url'] ?? "",
    //         filename: item['file_name'] ?? "",
    //         savedDir: item['saved_dir'] ?? "",
    //         timeCreated: item['time_created'] ?? 0))
    //     .toList();
    try {
      currentTasks = await FlutterDownloader.loadTasks() ?? [];
    } catch (e) {
      ChanLogger.e("Failed to load tasks: ", e);
    }

    for (PostItem post in model.allMediaPosts) {
      await downloadPostMedia(post);
    }
  }

  Future<void> downloadPostMedia(PostItem post) async {
    bool fileExists = _chanStorage.mediaFileExists(post.getMediaUrl()!, post.getCacheDirective());
    DownloadTask? existingTask = currentTasks.firstWhereOrNull((element) => element.url == post.getMediaUrl2());

    if (existingTask == null) {
      await _requestDownload(_TaskInfo(post));
      return;
    }
    if ([DownloadTaskStatus.enqueued, DownloadTaskStatus.running].contains(existingTask.status)) {
      print("Url is already enqueued to download. Skipping.");
      return;
    }
    if ([DownloadTaskStatus.complete, DownloadTaskStatus.failed, DownloadTaskStatus.canceled].contains(existingTask.status)) {
      if (fileExists) {
        return;
      } else {
        await _requestDownload(_TaskInfo(post));
        // await Future.delayed(Duration(microseconds: 200));
      }
    }
  }

  Future<void> _requestDownload(_TaskInfo task) async {
    String? taskId = await FlutterDownloader.enqueue(
      url: task.url!,
      savedDir: task.getCacheDir(_chanStorage),
      showNotification: false,
      openFileFromNotification: false,
    );

    if (taskId != null) {
      task.taskId = taskId;
      taskList.add(task);
    }
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    print('Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    final SendPort port = IsolateNameServer.lookupPortByName(Constants.downloaderPortName)!;
    port.send([id, status, progress]);
    print('Message sent.');
  }

  static Future<void> onDownloadFinished(String taskId) async {
    _TaskInfo? task = taskList.firstWhereOrNull((element) => element.taskId == taskId);
    if (task != null && task.post.isWebm()) {
      await ChanRepository.createVideoThumbnail(task.post);
    }
  }

  Future<void> cancelAllDownloads() async {
    return FlutterDownloader.cancelAll();
  }

  Future<void> cancelThreadDownload(ThreadDetailModel model) async {
    for (PostItem post in model.allMediaPosts) {
      _TaskInfo? task = taskList.firstWhereOrNull((element) => element.post.postId == post.postId);
      if (task != null) {
        await FlutterDownloader.cancel(taskId: task.taskId);
      }
    }
  }
}

class _TaskInfo {
  final PostItem post;
  String taskId = "";
  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  String? get url => post.getMediaUrl();

  String? get fileName => post.filename;

  String getCacheDir(ChanStorage cache) => cache.getFolderAbsolutePath(post.getCacheDirective());

  _TaskInfo(this.post);
}
