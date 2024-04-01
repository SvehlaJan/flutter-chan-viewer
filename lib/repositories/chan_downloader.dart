import 'package:flutter_chan_viewer/data/local/download_item.dart';
import 'package:flutter_chan_viewer/utils/media_helper.dart';

typedef DownloadStatusCallback = Future<void> Function(DownloadItem item);

abstract class ChanDownloader {
  Future<void> downloadMedia(
    MediaMetadata media, {
    DownloadStatusCallback? statusCallback,
  });

  Future<void> downloadItem(
    DownloadItem item, {
    DownloadStatusCallback? statusCallback,
  });

  Future<void> cancelAllDownloads();

  Future<void> cancelMediaDownload(MediaMetadata metadata);

  Future<bool> isMediaDownloaded(MediaMetadata metadata);
}
