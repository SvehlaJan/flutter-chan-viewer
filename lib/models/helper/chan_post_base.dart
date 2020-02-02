import 'package:flutter_chan_viewer/api/chan_api_provider.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';

abstract class ChanPostBase {
  final String boardId;
  final int threadId;
  final int timestamp;
  final String subtitle;
  final String content;
  final String filename;
  final String imageId;
  final String extension;

  ChanPostBase(this.boardId, this.threadId, this.timestamp, this.subtitle, this.content, this.filename, this.imageId, this.extension);

  bool hasImage() => [".jpg", ".png", ".gif", ".webp"].contains(extension);

  bool hasVideo() => [".webm"].contains(extension);

  bool hasMedia() => filename?.isNotEmpty ?? false;

  String getMediaUrl() => _getMediaUrl(this.boardId, this.imageId, this.extension, false);

  String getImageUrl() => hasImage() ? _getMediaUrl(this.boardId, this.imageId, this.extension, false) : null;

  String getThumbnailUrl() => _getMediaUrl(this.boardId, this.imageId, this.extension, true);

  String _getMediaUrl(String boardId, String imageId, String extension, bool thumbnail) {
    if (boardId != null && imageId != null && extension != null) {
      String fileName = _getFileName(imageId, extension, thumbnail);
      return "${ChanApiProvider.baseImageUrl}/$boardId/$fileName";
    } else {
      return null;
    }
  }

  String _getFileName(String imageId, String extension, bool thumbnail) {
    String targetImageId = thumbnail ? "${imageId}s" : imageId;
    String targetExtension = thumbnail ? ".jpg" : extension;
    return "$targetImageId$targetExtension";
  }

  CacheDirective getCacheDirective() => CacheDirective(boardId, threadId);

  List<Object> get props => [boardId, threadId, timestamp, subtitle, content, filename, imageId, extension];
}
