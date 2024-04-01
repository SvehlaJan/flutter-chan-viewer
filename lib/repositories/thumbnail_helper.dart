import 'dart:collection';
import 'dart:io';

import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';
import 'package:flutter_chan_viewer/models/helper/media_file_name.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/log_utils.dart';
import 'package:flutter_chan_viewer/utils/media_helper.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ThumbnailHelper with ChanLogger {
  final ChanStorage chanStorage;

  final ListQueue<MediaMetadata> _thumbnailQueue = ListQueue();

  bool _isProcessingQueue = false;

  ThumbnailHelper._(this.chanStorage);

  static Future<ThumbnailHelper> create(ChanStorage chanStorage) async {
    return ThumbnailHelper._(chanStorage);
  }

  File? getVideoThumbnail(MediaMetadata video) {
    MediaFileName thumbnailFileName = video.getFileName(ChanPostMediaType.VIDEO_THUMBNAIL);
    File? imageFile = chanStorage.getMediaFile(thumbnailFileName, video.cacheDirective);
    if (imageFile != null && imageFile.existsSync()) {
      return imageFile;
    }
    return null;
  }

  void enqueueVideoThumbnail(MediaMetadata video) {
    _thumbnailQueue.add(video);
    if (!_isProcessingQueue) {
      _isProcessingQueue = true;
      _processQueue();
    }
  }

  Future<void> _processQueue() async {
    while (_thumbnailQueue.isNotEmpty) {
      MediaMetadata video = _thumbnailQueue.removeFirst();
      await _createVideoThumbnail(video);
    }
    _isProcessingQueue = false;
  }

  Future<File?> _createVideoThumbnail(MediaMetadata video) async {
    MediaFileName thumbnailFileName = video.getFileName(ChanPostMediaType.VIDEO_THUMBNAIL);
    final fileExists = await chanStorage.mediaFileExists(thumbnailFileName, video.cacheDirective);
    if (fileExists) {
      // logDebug("Video thumbnail for ${video.filename} already exists");
      return null;
    }

    String videoPath = chanStorage.getFileAbsolutePath(
      video.getFileName(ChanPostMediaType.MAIN),
      video.cacheDirective,
    );

    try {
      // logDebug("Creating video thumbnail for ${videoPath}");
      final data = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 256,
        quality: 80,
      );
      // final data = await VideoCompress.getByteThumbnail(
      //     videoPath,
      //     quality: 50, // default(100)
      //     position: -1 // default(-1)
      // );
      if (data != null) {
        logDebug("Video thumbnail for ${video.filename} created");
        await chanStorage.writeMediaFile(thumbnailFileName, video.cacheDirective, data);
      } else {
        logError("Error creating video thumbnail: data is null");
      }
    } catch (e) {
      logError("Error creating video thumbnail: $e");
    }
    return null;
  }
}
