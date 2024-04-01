import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter_chan_viewer/data/local/download_item.dart';
import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';
import 'package:flutter_chan_viewer/models/helper/media_file_name.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/log_utils.dart';
import 'package:flutter_chan_viewer/utils/media_helper.dart';
import 'package:internet_file/internet_file.dart';
import 'package:internet_file/storage_io.dart';
import 'package:path_provider/path_provider.dart';

class ChanDownloaderNew extends ChanDownloader with ChanLogger {
  static const int CACHE_MAX_SIZE = 10;

  final ChanStorage _chanStorage;

  final storageIO = InternetFileStorageIO();

  ChanDownloaderNew._(this._chanStorage);

  static Future<ChanDownloaderNew> create(ChanStorage chanStorage) async {
    final downloader = ChanDownloaderNew._(chanStorage);
    var dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    return downloader;
  }

  @override
  Future<void> downloadMedia(
    MediaMetadata media, {
    DownloadStatusCallback? statusCallback,
  }) async {
    await _chanStorage.createDirectory(media.cacheDirective);

    String targetPath = _chanStorage.getFolderAbsolutePath(media.cacheDirective);
    MediaFileName fileName = media.getFileName(ChanPostMediaType.MAIN);
    DownloadItem item = new DownloadItem(
      media.mediaId.toString(),
      media.getMediaUrl(ChanPostMediaType.MAIN),
      targetPath,
      fileName.toString(),
      DownloadStatus.ENQUEUED,
      0,
      DateTime.now().millisecondsSinceEpoch,
    );

    await statusCallback?.call(item);
    await _startDownload(item, statusCallback);
  }

  @override
  Future<void> downloadItem(
    DownloadItem item, {
    DownloadStatusCallback? statusCallback,
  }) async {
    await _startDownload(item, statusCallback);
  }

  Future<void> _startDownload(DownloadItem item, DownloadStatusCallback? statusCallback) async {
    var previousProgress = -100;

    // create folder if not exists
    if (!await Directory(item.path).exists()) {
      await Directory(item.path).create(recursive: true);
    }

    logDebug("Downloading item: ${item.mediaId}");
    await InternetFile.get(
      item.url,
      storage: storageIO,
      storageAdditional: {
        'filename': item.filename,
        'location': item.path,
      },
      progress: (receivedLength, contentLength) async {
        final progress = (receivedLength / contentLength * 100).round();
        // update progress only if it's changed by more than 10%
        if (progress - previousProgress >= 10 && progress < 100) {
          previousProgress = progress;

          unawaited(statusCallback?.call(item.copyWith(progress: progress)));
        }
      },
    );

    statusCallback?.call(item.copyWith(status: DownloadStatus.FINISHED, progress: 100));
  }

  @override
  Future<void> cancelAllDownloads() async {
    // return FlutterDownloader.cancelAll();
  }

  @override
  Future<void> cancelMediaDownload(MediaMetadata media) async {
    // return FlutterDownloader.cancel(taskId: media.mediaId.toString());
  }

  @override
  Future<bool> isMediaDownloaded(MediaMetadata metadata) async {
    MediaFileName fileName = metadata.getFileName(ChanPostMediaType.MAIN);
    bool downloaded = await _chanStorage.mediaFileExists(fileName, metadata.cacheDirective);
    return downloaded;
  }
}
