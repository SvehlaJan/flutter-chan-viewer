import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter_chan_viewer/data/local/dao/downloads_dao.dart';
import 'package:flutter_chan_viewer/data/local/download_item.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:internet_file/internet_file.dart';
import 'package:internet_file/storage_io.dart';
import 'package:path_provider/path_provider.dart';

import 'chan_repository.dart';

class ChanDownloaderNew extends ChanDownloader {
  static const int CACHE_MAX_SIZE = 10;

  late ChanStorage _chanStorage;
  late DownloadsDao _downloadsDao = getIt<DownloadsDao>();

  final storageIO = InternetFileStorageIO();

  @override
  Future<void> initializeAsync() async {
    _chanStorage = await getIt.getAsync<ChanStorage>();

    var dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
  }

  @override
  Future<void> downloadThreadMedia(ThreadDetailModel model) async {
    _chanStorage.createDirectory(model.cacheDirective);

    for (PostItem post in model.allMediaPosts) {
      await downloadPostMedia(post);
    }
  }

  @override
  Future<void> downloadPostMedia(PostItem post) async {
    bool fileExists = _chanStorage.mediaFileExists(post.getMediaUrl()!, post.getCacheDirective());
    DownloadItem? existingTask = (await _downloadsDao.getDownloadById(post.imageId!)).toDownloadsItem();

    if (existingTask == null) {
      await _requestDownload(post);
      return;
    }
    if ([DownloadStatus.ENQUEUED, DownloadStatus.RUNNING].contains(existingTask.status)) {
      print("Url is already enqueued to download. Skipping.");
      return;
    }
    if ([DownloadStatus.FINISHED, DownloadStatus.FAILED, DownloadStatus.DELETED]
        .contains(existingTask.status)) {
      if (fileExists) {
        return;
      } else {
        await _requestDownload(post);
      }
    }
  }

  Future<void> _requestDownload(PostItem post) async {
    String path = _chanStorage.getFolderAbsolutePath(post.getCacheDirective());
    DownloadItem item = new DownloadItem(
      post.imageId!,
      post.getMediaUrl2(),
      path,
      post.filenameWithExtension(),
      DownloadStatus.ENQUEUED,
      0,
      DateTime.now().millisecondsSinceEpoch,
    );
    await _downloadsDao.insertDownload(item.toTableData());
    await _startDownload(item);
  }

  Future<void> _startDownload(DownloadItem item) async {
    await InternetFile.get(
      item.url,
      storage: storageIO,
      storageAdditional: {
        'filename': item.filename,
        'location': item.path,
      },
      process: (percentage) async {
        print("Download progress: ${percentage}");
        await _downloadsDao.updateDownload(item.copyWith(progress: percentage.toInt()).toTableData());
      }
    );
  }

  @override
  Future<void> cancelAllDownloads() async {
    // return FlutterDownloader.cancelAll();
  }

  @override
  Future<void> cancelThreadDownload(ThreadDetailModel model) async {
    for (PostItem post in model.allMediaPosts) {
      DownloadItem? task = (await _downloadsDao.getDownloadById(post.imageId!)).toDownloadsItem();
      if (task != null) {
        // await FlutterDownloader.cancel(taskId: task.taskId);
      }
    }
  }
}
