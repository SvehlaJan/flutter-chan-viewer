import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/data/local/downloads_db.dart';
import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/media_helper.dart';

enum DownloadStatus { ENQUEUED, RUNNING, PAUSED, FINISHED, FAILED, DELETED }

class DownloadItem extends Equatable {
  final String mediaId;
  final String url;
  final String path;
  final String filename;
  final DownloadStatus status;
  final int progress;
  final int timestamp;

  DownloadItem(this.mediaId, this.url, this.path, this.filename, this.status, this.progress, this.timestamp);

  DownloadsTableData toTableData() => DownloadsTableData(
        mediaId: mediaId,
        url: url,
        path: path,
        filename: filename,
        status: status.index,
        progress: progress,
        timestamp: timestamp,
      );

  factory DownloadItem.fromTableData(DownloadsTableData entry) => DownloadItem(
        entry.mediaId,
        entry.url,
        entry.path,
        entry.filename,
        DownloadStatus.values[entry.status],
        entry.progress,
        entry.timestamp,
      );

  DownloadItem copyWith(
          {String? mediaId,
          String? url,
          String? path,
          String? filename,
          DownloadStatus? status,
          int? progress,
          int? timestamp}) =>
      new DownloadItem(
        mediaId ?? this.mediaId,
        url ?? this.url,
        path ?? this.path,
        filename ?? this.filename,
        status ?? this.status,
        progress ?? this.progress,
        timestamp ?? this.timestamp,
      );

  @override
  List<Object?> get props => [mediaId, url, path, filename, status, progress, timestamp];
}

extension DownloadsTableDataExtension on DownloadsTableData? {
  DownloadItem? toDownloadsItem() => this != null ? DownloadItem.fromTableData(this!) : null;
}

extension MediaMetadataExtension on MediaMetadata {
  DownloadItem toDownloadsItem(ChanStorage chanStorage) {
    final url = getMediaUrl(ChanPostMediaType.MAIN);
    final targetPath = chanStorage.getFolderAbsolutePath(cacheDirective);
    final fileName = getFileName(ChanPostMediaType.MAIN).toString();
    return DownloadItem(
      mediaId.toString(),
      url,
      targetPath,
      fileName,
      DownloadStatus.ENQUEUED,
      0,
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}
