import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/data/local/downloads_db.dart';

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
      new DownloadItem(mediaId ?? this.mediaId, url ?? this.url, path ?? this.path, filename ?? this.filename,
          status ?? this.status, progress ?? this.progress, timestamp ?? this.timestamp);

  @override
  List<Object?> get props => [mediaId, url, path, filename, status, progress, timestamp];
}

extension DownloadsTableDataExtension on DownloadsTableData? {
  DownloadItem? toDownloadsItem() => this != null ? DownloadItem.fromTableData(this!) : null;
}
