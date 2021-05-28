import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/utils/flavor_config.dart';

enum ChanPostMediaType { MAIN, THUMBNAIL, VIDEO_THUMBNAIL }

abstract class ChanPostBase {
  final String boardId;
  final int threadId;
  final int timestamp;
  final String? subtitle;
  final String? htmlContent;
  final String? filename;
  final String? imageId;
  final String? extension;

  const ChanPostBase({
    required this.boardId,
    required this.threadId,
    required this.timestamp,
    required this.subtitle,
    required this.htmlContent,
    required this.filename,
    required this.imageId,
    required this.extension,
  });

  bool isFavorite();

  bool isImage() => [".jpg", ".png", ".webp", ".gif"].contains(extension);

  bool isGif() => [".gif"].contains(extension);

  bool isWebm() => [".webm"].contains(extension);

  bool hasMedia() => filename?.isNotEmpty ?? false;

  String? getMediaUrl() => _getMediaUrl(this.boardId, this.imageId, this.extension, false);

  String? getThumbnailUrl() => _getMediaUrl(this.boardId, this.imageId, this.extension, true);

  String? get content => ChanUtil.getPlainString(htmlContent);

  String? getTextContent({bool truncate = false}) {
    return ChanUtil.getReadableHtml(htmlContent, truncate);
  }

  String? _getMediaUrl(String? boardId, String? imageId, String? extension, bool thumbnail) {
    if (boardId != null && imageId != null && extension != null) {
      String targetImageId = thumbnail ? "${imageId}s" : imageId;
      String targetExtension = thumbnail ? ".jpg" : extension;
      String fileName = "$targetImageId$targetExtension";
      return "${FlavorConfig.values().baseImgUrl}/$boardId/$fileName";
    } else {
      return null;
    }
  }

  String getMediaUrl2({ChanPostMediaType type = ChanPostMediaType.MAIN}) {
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
      throw NullThrownError();
    }
  }

  CacheDirective getCacheDirective() => CacheDirective(boardId, threadId);

  List<Object?> get props => [boardId, threadId, timestamp, subtitle, htmlContent, filename, imageId, extension];
}
