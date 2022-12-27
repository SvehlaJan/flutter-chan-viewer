import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class ChanDownloaderImpl extends ChanDownloader {
  final logger = Logger();
  static const int CACHE_MAX_SIZE = 10;

  late ChanStorage _chanStorage;
  static List<_TaskInfo> taskList = [];

  @override
  Future<void> initializeAsync() async {
    _chanStorage = await getIt.getAsync<ChanStorage>();

    WidgetsFlutterBinding.ensureInitialized();
    await FlutterDownloader.initialize();
    FlutterDownloader.registerCallback(ChanDownloaderImpl.downloadCallback);

    var dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
  }

  @override
  Future<void> downloadThreadMedia(ThreadDetailModel model) async {
    _chanStorage.createDirectory(model.cacheDirective);

    try {
      var currentTasks = await FlutterDownloader.loadTasks() ?? [];
      for (PostItem post in model.allMediaPosts) {
        await _downloadPostMedia(post, currentTasks);
      }
    } catch (e) {
      logger.e("Failed to load tasks: ", e);
    }
  }

  Future<void> _downloadPostMedia(PostItem post, List<DownloadTask> allTasks) async {
    bool fileExists = _chanStorage.mediaFileExists(post.getMediaUrl()!, post.getCacheDirective());
    List<DownloadTask> existingTasks = allTasks.where((element) => element.url == post.getMediaUrl2()).toList();
    DownloadTask? existingTask = existingTasks.isEmpty ? null : existingTasks.reduce((value, element) => value.timeCreated > element.timeCreated ? value : element);

    if (existingTask == null) {
      await _requestDownload(_TaskInfo(post));
      return;
    }

    if ([DownloadTaskStatus.enqueued, DownloadTaskStatus.running].contains(existingTask.status)) {
      logger.i("Url is already enqueued to download. Skipping. ${existingTask.status}");
      return;
    }
    if ([DownloadTaskStatus.complete, DownloadTaskStatus.failed, DownloadTaskStatus.canceled]
        .contains(existingTask.status)) {
      if (fileExists) {
        return;
      } else {
        await _requestDownload(_TaskInfo(post));
      }
    }
  }

  Future<void> _requestDownload(_TaskInfo task) async {
    String dirPath = task.getCacheDir(_chanStorage);
    String? taskId = await FlutterDownloader.enqueue(
      url: task.url!,
      savedDir: dirPath,
      showNotification: false,
      openFileFromNotification: false,
    );

    if (taskId != null) {
      task.taskId = taskId;
      taskList.add(task);
    }
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    _TaskInfo? task = taskList.firstWhereOrNull((element) => element.taskId == id);
    if (task != null) {
      final SendPort port = IsolateNameServer.lookupPortByName(Constants.downloaderPortName)!;
      port.send([task.post.postId, progress]);
    }
    // Logger().i('Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
  }

  @override
  Future<void> cancelAllDownloads() async {
    return FlutterDownloader.cancelAll();
  }

  @override
  Future<void> cancelThreadDownload(ThreadDetailModel model) async {
    for (PostItem post in model.allMediaPosts) {
      _TaskInfo? task = taskList.firstWhereOrNull((element) => element.post.postId == post.postId);
      if (task != null) {
        await FlutterDownloader.cancel(taskId: task.taskId);
      }
    }
  }

  @override
  bool isPostMediaDownloaded(ChanPostBase post) {
    bool fileExists = _chanStorage.mediaFileExists(post.getMediaUrl()!, post.getCacheDirective());
    List<_TaskInfo> existingTasks = taskList.where((element) => element.url == post.getMediaUrl2()).toList();
    _TaskInfo? existingTask = existingTasks.isEmpty ? null : existingTasks.reduce((value, element) => value.timeCreated > element.timeCreated ? value : element);
    bool isInProgress = existingTask != null && [DownloadTaskStatus.enqueued, DownloadTaskStatus.running].contains(existingTask.status);
    return !isInProgress && fileExists;
  }
}

class _TaskInfo {
  final PostItem post;
  final int timeCreated = DateTime.now().millisecondsSinceEpoch;
  String taskId = "";
  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  String? get url => post.getMediaUrl();

  String getCacheDir(ChanStorage cache) => cache.getFolderAbsolutePath(post.getCacheDirective());

  _TaskInfo(this.post);
}
