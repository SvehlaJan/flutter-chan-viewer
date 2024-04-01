import 'package:flutter/foundation.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/utils/download_helper.dart';

enum ChanPostMediaType { MAIN, THUMBNAIL, VIDEO_THUMBNAIL }

@immutable
abstract class ChanPostBase {
  final String boardId;
  final int threadId;
  final int timestamp;
  final String? subtitle;
  final String? htmlContent;
  final String? filename;
  final String? imageId;
  final String? extension;
  final int downloadProgress;

  const ChanPostBase({
    required this.boardId,
    required this.threadId,
    required this.timestamp,
    required this.subtitle,
    required this.htmlContent,
    required this.filename,
    required this.imageId,
    required this.extension,
    this.downloadProgress = -1,
  });

  bool isFavorite();

  bool hasMedia() => filename?.isNotEmpty ?? false;

  String? get content => ChanUtil.getPlainString(htmlContent);

  @deprecated
  bool get isMediaDownloaded => downloadProgress == ChanDownloadProgress.FINISHED.value;

  get cacheDirective => CacheDirective(boardId, threadId);

  List<Object?> get props => [boardId, threadId, timestamp, subtitle, htmlContent, filename, imageId, extension];
}
