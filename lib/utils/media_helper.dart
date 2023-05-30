import 'dart:io';

import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';
import 'package:flutter_chan_viewer/models/helper/media_type.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/repositories/thumbnail_helper.dart';

class MediaHelper {
  static ImageSource? getThreadThumbnailSource(ThreadItem thread) {
    if (!thread.hasMedia()) {
      return null;
    }

    bool isDownloaded = getIt<ChanDownloader>().isMediaDownloaded(thread);
    if (isDownloaded && thread.mediaType.isImageOrGif()) {
      String filePath = getIt<ChanStorage>()
          .getMediaFile(
            thread.getMediaUrl(ChanPostMediaType.MAIN),
            thread.getCacheDirective(),
          )!
          .path;
      return FileImageSource(filePath, thread.threadId);
    }

    if (thread.isFavorite() && thread.mediaType.isWebm() && isDownloaded) {
      File? thumbnailFile = ThumbnailHelper.getVideoThumbnail(thread);
      if (thumbnailFile != null) {
        return FileImageSource(thumbnailFile.path, thread.threadId);
      }
    }

    if (thread.mediaType.isWebm()) {
      return NetworkImageSource(
        thread.getMediaUrl(ChanPostMediaType.THUMBNAIL),
        null,
        thread.threadId,
      );
    } else {
      return NetworkImageSource(
        thread.getMediaUrl(ChanPostMediaType.MAIN),
        thread.getMediaUrl(ChanPostMediaType.THUMBNAIL),
        thread.threadId,
      );
    }
  }

  static MediaSource? getMediaSource(PostItem post) {
    if (post.mediaType.isImageOrGif()) {
      return getImageSource(post, false);
    } else if (post.mediaType.isWebm()) {
      return getVideoSource(post);
    } else {
      return null;
    }
  }

  static ImageSource getImageSource(PostItem post, bool forceThumbnail) {
    if (post.isMediaDownloaded && post.mediaType.isImageOrGif()) {
      String filePath = getIt<ChanStorage>()
          .getMediaFile(
            post.getMediaUrl(ChanPostMediaType.MAIN),
            post.getCacheDirective(),
          )!
          .path;
      return FileImageSource(filePath, post.postId);
    }

    if (post.isFavorite() && post.mediaType.isWebm() && post.isMediaDownloaded) {
      File? thumbnailFile = ThumbnailHelper.getVideoThumbnail(post);
      if (thumbnailFile != null) {
        return FileImageSource(thumbnailFile.path, post.postId);
      }
    }

    if (forceThumbnail || post.mediaType.isWebm()) {
      return NetworkImageSource(
        post.getMediaUrl(ChanPostMediaType.THUMBNAIL),
        null,
        post.postId,
      );
    } else {
      return NetworkImageSource(
        post.getMediaUrl(ChanPostMediaType.MAIN),
        post.getMediaUrl(ChanPostMediaType.THUMBNAIL),
        post.postId,
      );
    }
  }

  static VideoSource getVideoSource(PostItem post) {
    ImageSource placeholderImage = getImageSource(post, false);

    if (post.isMediaDownloaded) {
      String filePath = getIt<ChanStorage>()
          .getMediaFile(
            post.getMediaUrl(ChanPostMediaType.MAIN),
            post.getCacheDirective(),
          )!
          .path;
      return FileVideoSource(filePath, post.postId, placeholderImage);
    }

    return NetworkVideoSource(post.getMediaUrl(ChanPostMediaType.MAIN), post.postId, placeholderImage);
  }
}

sealed class MediaSource {
  final int postId;

  MediaSource(this.postId);

  ImageSource asImageSource() {
    if (this is ImageSource) {
      return this as ImageSource;
    } else if (this is VideoSource) {
      return (this as VideoSource).placeholderSource;
    } else {
      throw Exception("MediaSource is not an ImageSource");
    }
  }

  VideoSource asVideoSource() {
    if (this is VideoSource) {
      return this as VideoSource;
    } else {
      throw Exception("MediaSource is not a VideoSource");
    }
  }
}

sealed class ImageSource extends MediaSource {
  ImageSource(int postId) : super(postId);
}

class NetworkImageSource extends ImageSource {
  final String mainUrl;
  final String? thumbnailUrl;

  NetworkImageSource(this.mainUrl, this.thumbnailUrl, int postId) : super(postId);
}

class FileImageSource extends ImageSource {
  final String filePath;

  FileImageSource(this.filePath, int postId) : super(postId);
}

sealed class VideoSource extends MediaSource {
  final ImageSource placeholderSource;

  VideoSource(this.placeholderSource, int postId) : super(postId);
}

class NetworkVideoSource extends VideoSource {
  final String url;

  NetworkVideoSource(this.url, int postId, ImageSource placeholderImage) : super(placeholderImage, postId);
}

class FileVideoSource extends VideoSource {
  final String filePath;

  FileVideoSource(this.filePath, int postId, ImageSource placeholderImage) : super(placeholderImage, postId);
}

extension PostItemMediaExtension on PostItem {
  MediaSource? getMediaSource() => MediaHelper.getMediaSource(this);

  ImageSource getThumbnailImageSource() => MediaHelper.getImageSource(this, true);
}

extension ThreadItemMediaExtension on ThreadItem {
  ImageSource? getThumbnailImageSource() => MediaHelper.getThreadThumbnailSource(this);
}
