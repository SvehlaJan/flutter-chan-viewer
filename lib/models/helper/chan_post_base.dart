import 'package:flutter/foundation.dart';
import 'package:flutter_chan_viewer/models/helper/media_type.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/utils/download_helper.dart';
import 'package:flutter_chan_viewer/utils/flavor_config.dart';

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

  String? get filenameWithExtension => filename != null && extension != null ? "${filename}${extension}" : null;

  String? get content => ChanUtil.getPlainString(htmlContent);

  bool get isMediaDownloaded => downloadProgress == ChanDownloadProgress.FINISHED.value;

  MediaType get mediaType {
    if ([".jpg", ".png", ".webp"].contains(extension)) {
      return MediaType.IMAGE;
    } else if ([".webm"].contains(extension)) {
      return MediaType.WEBM;
    } else if ([".gif"].contains(extension)) {
      return MediaType.GIF;
    } else {
      return MediaType.NONE;
    }
  }

  String getMediaUrl(ChanPostMediaType type) {
    if (this.imageId != null && this.extension != null) {
      String targetImageId = "";
      String targetExtension = "";
      switch (type) {
        case ChanPostMediaType.MAIN:
          targetImageId = this.imageId!;
          targetExtension = this.extension!;
          break;
        case ChanPostMediaType.THUMBNAIL:
          targetImageId = "${imageId}s";
          targetExtension = ".jpg";
          break;
        case ChanPostMediaType.VIDEO_THUMBNAIL:
          targetImageId = "${imageId}t";
          targetExtension = ".jpg";
          break;
      }
      String fileName = "$targetImageId$targetExtension";
      return "${FlavorConfig.values().baseImgUrl}/$boardId/$fileName";
    } else {
      throw Exception("Media URL not available");
    }
  }

  CacheDirective getCacheDirective() => CacheDirective(boardId, threadId);

  List<Object?> get props => [boardId, threadId, timestamp, subtitle, htmlContent, filename, imageId, extension];
}
