import 'dart:collection';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter_chan_viewer/data/local/dao/downloads_dao.dart';
import 'package:flutter_chan_viewer/data/local/download_item.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/repositories/thumbnail_helper.dart';
import 'package:flutter_chan_viewer/utils/log_utils.dart';
import 'package:flutter_chan_viewer/utils/media_helper.dart';
import 'package:path/path.dart';

typedef DownloadProgressCallback = void Function(DownloadItem item);

class BackgroundDownloader with ChanLogger {
  final ReceivePort _receivePort = ReceivePort();
  final SendPort _sendPort;
  final ChanDownloader _chanDownloader;
  final DownloadsDao _downloadsDao;
  final ChanStorage _chanStorage;
  final ThumbnailHelper _thumbnailHelper;

  final HashMap<String, MediaMetadata> _mediaCache = HashMap();
  
  bool _isRunning = false;

  late DownloadProgressCallback _progressCallback;

  static BackgroundDownloader? _instance;

  static Future<BackgroundDownloader> getInstance(
    SendPort sendPort,
    ChanDownloader chanDownloader,
    DownloadsDao downloadsDao,
    ChanStorage chanStorage,
    ThumbnailHelper thumbnailHelper,
  ) {
    if (_instance == null) {
      print("Creating background downloader instance");
      _instance = BackgroundDownloader._(sendPort, chanDownloader, downloadsDao, chanStorage, thumbnailHelper);
    }
    return Future.value(_instance!);
  }

  BackgroundDownloader._(
    this._sendPort,
    this._chanDownloader,
    this._downloadsDao,
    this._chanStorage,
    this._thumbnailHelper,
  ) {
    logDebug("Background downloader created");

    _receivePort.listen((dynamic data) async {
      if (data is List<MediaMetadata>) {
        for (final media in data) {
          final item = media.toDownloadsItem(_chanStorage);
          _mediaCache[item.mediaId] = media;
          await _enqueueDownloadItem(item);
        }
        _processQueue();
      } else {
        logError("background downloader received unknown data: $data");
      }
    });

    _progressCallback = (DownloadItem item) {
      if (item.progress == 100) {
        final mediaItem = _mediaCache[item.mediaId];
        if (mediaItem != null) {
          _onDownloadFinished(mediaItem);
        } else {
          logWarning("Media item not found: ${item.mediaId}");
        }
      }
      _sendPort.send(item);
    };

    _sendPort.send(_receivePort.sendPort);
  }

  Future<void> _enqueueDownloadItem(DownloadItem item) async {
    DownloadItem? existingTask = (await _downloadsDao.getDownloadById(item.mediaId.toString()))?.toDownloadsItem();

    if (existingTask == null) {
      _downloadsDao.insertDownload(item.copyWith(status: DownloadStatus.ENQUEUED).toTableData());
      return;
    } else if ([DownloadStatus.ENQUEUED, DownloadStatus.RUNNING].contains(existingTask.status)) {
      logDebug("Url is already enqueued to download. Skipping.");
      return;
    } else if ([DownloadStatus.FINISHED, DownloadStatus.FAILED, DownloadStatus.DELETED].contains(existingTask.status)) {
      bool fileExists = await File(join(item.path, item.filename)).exists();
      if (fileExists) {
        // logDebug("File already downloaded. Skipping.");
        _progressCallback.call(existingTask);
        return;
      } else {
        logDebug("Re-enqueuing download: ${item.mediaId}. Status: ${existingTask.status}");
        await _downloadsDao.insertDownload(item.copyWith(status: DownloadStatus.ENQUEUED).toTableData());
      }
    }
  }

  Future<void> _processQueue() async {
    logDebug("Processing download queue");
    if (_isRunning) {
      logDebug("Download queue is already running");
      return;
    }
    _isRunning = true;
    DownloadItem? nextItem;
    do {
      nextItem = (await _downloadsDao.getNextEnqueuedDownload())?.toDownloadsItem();
      if (nextItem != null) {
        try {
          await _chanDownloader.downloadItem(
            nextItem,
            statusCallback: (DownloadItem item) async {
              final status = item.progress == 100 ? DownloadStatus.FINISHED : DownloadStatus.RUNNING;
              final updatedItem = item.copyWith(status: status);
              await _downloadsDao.updateDownload(updatedItem.toTableData());
              _progressCallback(item);
            },
          );
        } catch (e, stacktrace) {
          logError("Error downloading item: ${nextItem.mediaId}", error: e, stackTrace: stacktrace);
          await _downloadsDao.insertDownload(nextItem.copyWith(status: DownloadStatus.FAILED).toTableData());
        }
      }
    } while (nextItem != null);
    logDebug("Download queue finished processing");

    _isRunning = false;
  }

  Future<void> _onDownloadFinished(MediaMetadata media) async {
    logDebug("Media download success: ${media.mediaId} - ${media.filename}");
    // TODO - move to a separate service and call from DownloadsRepository
    _thumbnailHelper.enqueueVideoThumbnail(media);
  }
}

class StartBackgroundDownloaderRequest {
  final SendPort sendPort;
  final rootIsolateToken;

  StartBackgroundDownloaderRequest(this.sendPort, this.rootIsolateToken);
}