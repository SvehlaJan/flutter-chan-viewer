import 'package:flutter_chan_viewer/api/chan_api_provider.dart';
import 'package:flutter_chan_viewer/utils/network_image/cache_directive.dart';

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

  bool hasMedia() => hasImage() || hasVideo();

  String getMediaUrl() => _getMediaUrl(this.boardId, this.imageId, this.extension, false);

  String getImageUrl() => hasImage() ? _getMediaUrl(this.boardId, this.imageId, this.extension, false) : null;

  String getThumbnailUrl() => _getMediaUrl(this.boardId, this.imageId, this.extension, true);

  String _getMediaUrl(String boardId, String imageId, String extension, [bool thumbnail = false]) {
    if (imageId != null && extension != null) {
      String targetImageId = thumbnail ? "${imageId}s" : imageId;
      String targetExtension = thumbnail ? ".jpg" : extension;
      return "${ChanApiProvider.baseImageUrl}/$boardId/$targetImageId$targetExtension";
    } else {
      return null;
    }
  }

  CacheDirective getCacheDirective() => CacheDirective(boardId, threadId);

  List<Object> get props => [boardId, threadId, timestamp, subtitle, content, filename, imageId, extension];
}
