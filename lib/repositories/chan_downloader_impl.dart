import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chan_viewer/data/local/download_item.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/log_utils.dart';
import 'package:flutter_chan_viewer/utils/media_helper.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class ChanDownloaderImpl extends ChanDownloader with ChanLogger {

  final ChanStorage _chanStorage;
  List<DownloadTask> _libraryTasks = [];
  List<_TaskInfo> _taskInfoList = [];
  ReceivePort _port = ReceivePort();

  ChanDownloaderImpl._(this._chanStorage);

  static Future<ChanDownloaderImpl> create() async {
    final downloader = ChanDownloaderImpl._(await getIt.getAsync<ChanStorage>());

    WidgetsFlutterBinding.ensureInitialized();
    await FlutterDownloader.initialize(debug: true);
    FlutterDownloader.registerCallback(ChanDownloaderImpl.downloadCallbackBackground);

    downloader._libraryTasks = await FlutterDownloader.loadTasks() ?? [];

    IsolateNameServer.registerPortWithName(downloader._port.sendPort, Constants.downloaderPortName);
    downloader._port.listen((dynamic data) {
      print("Download progress: $data");
      downloader.downloadCallbackMain(data[0], data[1], data[2]);
    });

    return downloader;
  }

  @override
  Future<void> downloadMedia(MediaMetadata media, {DownloadStatusCallback? statusCallback}) async {
    await _chanStorage.createDirectory(media.cacheDirective);

    try {
      await _downloadMedia(media);
    } catch (e) {
      logError("Failed to download thread media: ", error: e);
    }
  }

  @override
  Future<void> downloadItem(DownloadItem item, {DownloadStatusCallback? statusCallback}) async {}

  Future<void> _downloadMedia(MediaMetadata media) async {
    DownloadTask? existingTask = findDownloadTask(media.getMediaUrl(ChanPostMediaType.MAIN));
    if (existingTask == null) {
      await _requestDownload(_TaskInfo.fromMediaMetadata(media));
      return;
    }

    if ([DownloadTaskStatus.enqueued, DownloadTaskStatus.running].contains(existingTask.status)) {
      logDebug("Url is already enqueued to download. Skipping. ${existingTask.status}");
      return;
    }
    if ([DownloadTaskStatus.complete].contains(existingTask.status)) {
      final fileExists = await _chanStorage.mediaFileExists(
        media.getFileName(ChanPostMediaType.MAIN),
        media.cacheDirective,
      );
      if (fileExists) {
        logDebug("Url is already downloaded. Skipping. ${existingTask.status}");
        return;
      } else {
        logDebug("File is missing. Re-downloading. ${existingTask.status}");
        await _requestDownload(_TaskInfo.fromMediaMetadata(media));
        return;
      }
    }
    if ([DownloadTaskStatus.paused].contains(existingTask.status)) {
      logDebug("Url is already paused. Resuming. ${existingTask.status}");
      await FlutterDownloader.resume(taskId: existingTask.taskId);
      return;
    }
    if ([
      DownloadTaskStatus.failed,
      DownloadTaskStatus.canceled,
      DownloadTaskStatus.undefined,
    ].contains(existingTask.status)) {
      await _requestDownload(_TaskInfo.fromMediaMetadata(media));
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
    DownloadTaskStatus taskStatus = DownloadTaskStatus.fromInt(status);
    _TaskInfo? task = _taskInfoList.firstWhereOrNull((element) => element.taskId == id);
    if (task != null) {
      if (taskStatus == DownloadTaskStatus.complete) {
      } else if (taskStatus == DownloadTaskStatus.failed) {
        logDebug("Failed to download: ${task.filename} . Deleting file.");
        await getIt.get<ChanStorage>().deleteMediaFile(task.filename, task.cacheDirective);
        logDebug("File deleted.");
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
  Future<void> cancelMediaDownload(MediaMetadata media) async {
    _TaskInfo? task = _taskInfoList.firstWhereOrNull((element) => element.mediaId == media.mediaId);
    if (task != null) {
      await FlutterDownloader.cancel(taskId: task.taskId);
    }
  }

  @override
  Future<bool> isMediaDownloaded(MediaMetadata metadata) async {
    DownloadTask? task = findDownloadTask(metadata.getMediaUrl(ChanPostMediaType.MAIN));
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
  final int mediaId;
  final String url;
  final String filename;
  final CacheDirective cacheDirective;
  final int timeCreated = DateTime.now().millisecondsSinceEpoch;
  String taskId = "";
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  _TaskInfo({
    required this.mediaId,
    required this.url,
    required this.filename,
    required this.cacheDirective,
  });

  factory _TaskInfo.fromMediaMetadata(MediaMetadata media) {
    return _TaskInfo(
      mediaId: int.parse(media.imageId!),
      url: media.getMediaUrl(ChanPostMediaType.MAIN),
      filename: "${media.imageId}${media.extension}",
      cacheDirective: media.cacheDirective,
    );
  }
}
