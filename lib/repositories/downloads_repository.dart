import 'dart:async';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:flutter_chan_viewer/data/local/dao/downloads_dao.dart';
import 'package:flutter_chan_viewer/data/local/download_item.dart';
import 'package:flutter_chan_viewer/data/local/downloads_db.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader_new.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/repositories/thumbnail_helper.dart';
import 'package:flutter_chan_viewer/services/download_service.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/flavor_config.dart';
import 'package:flutter_chan_viewer/utils/log_utils.dart';
import 'package:flutter_chan_viewer/utils/media_helper.dart';

class DownloadsRepository with ChanLogger {
  final DownloadsDao _downloadsDao;
  final ChanDownloader _chanDownloader;
  ReceivePort _receivePort = ReceivePort();
  SendPort? _sendPort;
  static bool _isRunning = false;

  StreamController<DownloadItem> _downloadsStreamController = StreamController.broadcast();

  Stream<DownloadItem> get downloadsStream => _downloadsStreamController.stream;

  DownloadsRepository._(this._downloadsDao, this._chanDownloader);

  static Future<DownloadsRepository> create(
    DownloadsDao downloadsDao,
    ChanDownloader chanDownloader,
    ChanStorage chanStorage,
  ) async {
    final repository = DownloadsRepository._(downloadsDao, chanDownloader);
    return repository;
  }

  Future<void> enqueueDownloads(List<MediaMetadata> mediaList) async {
    if (_sendPort != null) {
      _sendPort?.send(mediaList);
    } else if (!_isRunning) {
      _isRunning = true;

      final request = StartBackgroundDownloaderRequest(
        _receivePort.sendPort,
        RootIsolateToken.instance!,
      );
      await Isolate.spawn(
        _startBackgroundDownloader,
        request,
      );
      _receivePort.listen((dynamic data) {
        if (data is SendPort) {
          _sendPort = data;
          // In case we just started the background downloader, we need to send the media list
          _sendPort?.send(mediaList);
        } else if (data is DownloadItem) {
          // logDebug("Received download progress: ${data.mediaId} - ${data.progress}");
          _downloadsStreamController.add(data);
        } else {
          logWarning("Received unknown data: $data");
        }
      });
    } else {
      logWarning("Download queue is already running but sendPort is null");
    }
  }

  static Future<void> _startBackgroundDownloader(StartBackgroundDownloaderRequest request) async {
    final sendPort = request.sendPort;
    final token = request.rootIsolateToken;
    BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    final downloadsDb = DownloadsDB.connect(DownloadsDB.createDriftIsolateAndConnect(token));
    final downloadsDao = DownloadsDao(downloadsDb);
    final chanStorage = await ChanStorage.create();
    final chanDownloader = await ChanDownloaderNew.create(chanStorage);
    final thumbnailHelper = await ThumbnailHelper.create(chanStorage);
    FlavorConfig.defaults(values: Constants.flavorDev);
    BackgroundDownloader.getInstance(
      sendPort,
      chanDownloader,
      downloadsDao,
      chanStorage,
      thumbnailHelper,
    );
  }

  Future<void> cancelMediaDownloads(List<MediaMetadata> mediaList) async {
    for (MediaMetadata media in mediaList) {
      DownloadItem? existingTask = (await _downloadsDao.getDownloadById(media.mediaId.toString()))?.toDownloadsItem();
      if (existingTask != null) {
        if ([DownloadStatus.ENQUEUED, DownloadStatus.RUNNING].contains(existingTask.status)) {
          await _chanDownloader.cancelMediaDownload(media);
        }
        await _downloadsDao.updateDownload(existingTask.copyWith(status: DownloadStatus.DELETED).toTableData());
      }
    }
  }
}
