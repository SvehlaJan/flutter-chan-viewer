import 'package:flutter_chan_viewer/data/local/download_item.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader.dart';
import 'package:flutter_chan_viewer/utils/media_helper.dart';

class ChanDownloaderMock extends ChanDownloader {
  @override
  Future<void> downloadMedia(MediaMetadata model, {DownloadStatusCallback? statusCallback}) async {}

  @override
  Future<void> downloadItem(DownloadItem item, {DownloadStatusCallback? statusCallback}) async {}

  @override
  Future<void> cancelMediaDownload(MediaMetadata model) async {}

  @override
  Future<void> cancelAllDownloads() async {}

  @override
  Future<bool> isMediaDownloaded(MediaMetadata metadata) {
    return Future.value(false);
  }
}
