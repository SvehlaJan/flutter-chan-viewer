import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/log_utils.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class ChanDownloaderImpl extends ChanDownloader {
  static final logger = LogUtils.getLogger();

  late ChanStorage _chanStorage;
  List<DownloadTask> _libraryTasks = [];
  List<_TaskInfo> _taskInfoList = [];
  ReceivePort _port = ReceivePort();

  @override
  Future<void> initializeAsync() async {
    _chanStorage = await getIt.getAsync<ChanStorage>();

    WidgetsFlutterBinding.ensureInitialized();
    await FlutterDownloader.initialize(debug: true);
    FlutterDownloader.registerCallback(ChanDownloaderImpl.downloadCallbackBackground);

    _libraryTasks = await FlutterDownloader.loadTasks() ?? [];

    IsolateNameServer.registerPortWithName(_port.sendPort, Constants.downloaderPortName);
    _port.listen((dynamic data) {
      downloadCallbackMain(data[0], data[1], data[2]);
    });
  }

  @override
  Future<void> downloadThreadMedia(ThreadDetailModel model) async {
    await _chanStorage.createDirectory(model.cacheDirective);

    try {
      for (PostItem post in model.allMediaPosts) {
        await _downloadPostMedia(post);
      }
    } catch (e) {
      logger.e("Failed to download thread media: ", e);
    }
  }

  Future<void> _downloadPostMedia(PostItem post) async {
    DownloadTask? existingTask = findDownloadTask(post.getMediaUrl(ChanPostMediaType.MAIN));
    if (existingTask == null) {
      await _requestDownload(_TaskInfo.fromPost(post));
      return;
    }

    if ([DownloadTaskStatus.enqueued, DownloadTaskStatus.running].contains(existingTask.status)) {
      logger.i("Url is already enqueued to download. Skipping. ${existingTask.status}");
      return;
    }
    if ([DownloadTaskStatus.complete].contains(existingTask.status)) {
      // logger.i("Url is already downloaded. Skipping. ${existingTask.status}");
      return;
    }
    if ([DownloadTaskStatus.paused].contains(existingTask.status)) {
      logger.i("Url is already paused. Resuming. ${existingTask.status}");
      await FlutterDownloader.resume(taskId: existingTask.taskId);
      return;
    }
    if ([
      DownloadTaskStatus.failed,
      DownloadTaskStatus.canceled,
      DownloadTaskStatus.undefined,
    ].contains(existingTask.status)) {
      await _requestDownload(_TaskInfo.fromPost(post));
    }
  }

  Future<void> _requestDownload(_TaskInfo task) async {
    String dirPath = _chanStorage.getFolderAbsolutePath(task.cacheDirective);
    String? taskId = await FlutterDownloader.enqueue(
      url: task.url,
      savedDir: dirPath,
      showNotification: true,
      openFileFromNotification: false,
    );

    if (taskId != null) {
      task.taskId = taskId;
      _taskInfoList.add(task);
    }
  }

  void downloadCallbackMain(String id, int status, int progress) async {
    DownloadTaskStatus taskStatus = DownloadTaskStatus(status);
    _TaskInfo? task = _taskInfoList.firstWhereOrNull((element) => element.taskId == id);
    if (task != null) {
      if (taskStatus == DownloadTaskStatus.complete) {
      } else if (taskStatus == DownloadTaskStatus.failed) {
        print("Failed to download: ${task.filename} . Deleting file.");
        await getIt.get<ChanStorage>().deleteMediaFile(task.filename, task.cacheDirective);
        print("File deleted.");
      } else if (taskStatus == DownloadTaskStatus.enqueued) {
      } else if (taskStatus == DownloadTaskStatus.running) {}
    }
  }

  static void downloadCallbackBackground(String id, int status, int progress) {
    final SendPort port = IsolateNameServer.lookupPortByName(Constants.downloaderPortName)!;
    port.send([id, status, progress]);
  }

  @override
  Future<void> cancelAllDownloads() async {
    return FlutterDownloader.cancelAll();
  }

  @override
  Future<void> cancelThreadDownload(ThreadDetailModel model) async {
    for (PostItem post in model.allMediaPosts) {
      _TaskInfo? task = _taskInfoList.firstWhereOrNull((element) => element.postId == post.postId);
      if (task != null) {
        await FlutterDownloader.cancel(taskId: task.taskId);
      }
    }
  }

  @override
  bool isMediaDownloaded(ChanPostBase post) {
    DownloadTask? task = findDownloadTask(post.getMediaUrl(ChanPostMediaType.MAIN));
    bool fileDownloaded = task != null && task.status == DownloadTaskStatus.complete;

    return fileDownloaded;
  }

  DownloadTask? findDownloadTask(String url) {
    List<DownloadTask> existingTasks = _libraryTasks.where((element) => element.url == url).toList();
    DownloadTask? task = existingTasks.isEmpty
        ? null
        : existingTasks.reduce((value, element) => value.timeCreated > element.timeCreated ? value : element);

    return task;
  }
}

class _TaskInfo {
  final int postId;
  final String url;
  final String filename;
  final CacheDirective cacheDirective;
  final int timeCreated = DateTime.now().millisecondsSinceEpoch;
  String taskId = "";
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  _TaskInfo({
    required this.postId,
    required this.url,
    required this.filename,
    required this.cacheDirective,
  });

  factory _TaskInfo.fromPost(PostItem post) {
    return _TaskInfo(
      postId: post.postId,
      url: post.getMediaUrl(ChanPostMediaType.MAIN),
      filename: "${post.imageId}${post.extension}",
      cacheDirective: post.getCacheDirective(),
    );
  }
}
