import 'dart:io';

import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:kt_dart/kt.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ThumbnailHelper {
  static File? getVideoThumbnail(ChanPostBase post) {
    String thumbnailUrl = post.getMediaUrl(ChanPostMediaType.VIDEO_THUMBNAIL);
    File? imageFile = getIt<ChanStorage>().getMediaFile(thumbnailUrl, post.getCacheDirective());
    if (imageFile != null && imageFile.existsSync()) {
      return imageFile;
    }
    return null;
  }

  static Future<File?> _createVideoThumbnail(KtPair<String, String> inOut) async {
    String? newFilePath = await VideoThumbnail.thumbnailFile(
        video: inOut.first,
        thumbnailPath: inOut.second,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 512,
        quality: 80);
    if (newFilePath != null && File(newFilePath).existsSync()) {
      return File(newFilePath);
    }
    return null;
  }

  static Future<File?> createVideoThumbnail(ChanPostBase post) async {
    String videoUrl = post.getMediaUrl(ChanPostMediaType.MAIN);
    String thumbnailUrl = post.getMediaUrl(ChanPostMediaType.VIDEO_THUMBNAIL);
    String videoPath = getIt<ChanStorage>().getFileAbsolutePath(videoUrl, post.getCacheDirective());
    String thumbnailPath = getIt<ChanStorage>().getFileAbsolutePath(thumbnailUrl, post.getCacheDirective());
    return await _createVideoThumbnail(KtPair(videoPath, thumbnailPath));
  }
}