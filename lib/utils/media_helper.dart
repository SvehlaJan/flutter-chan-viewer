import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';
import 'package:flutter_chan_viewer/models/helper/media_file_name.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/repositories/thumbnail_helper.dart';
import 'package:flutter_chan_viewer/utils/flavor_config.dart';

@immutable
class MediaMetadata extends Equatable {
  final String? imageId;
  final String? filename;
  final String? extension;
  final String boardId;
  final int threadId;
  final int mediaId;

  bool get isGif => extension == ".gif";

  bool get isWebm => extension == ".webm";

  bool get isImageOrGif => [".jpg", ".png", ".webp", ".gif"].contains(extension);

  CacheDirective get cacheDirective => CacheDirective(boardId, threadId);

  MediaMetadata({
    required this.imageId,
    required this.filename,
    required this.extension,
    required this.boardId,
    required this.threadId,
    required this.mediaId,
  });

  MediaFileName getFileName(ChanPostMediaType type) {
    if (imageId == null || extension == null || filename == null) {
      throw Exception("Media file is not available");
    }

    switch (type) {
      case ChanPostMediaType.MAIN:
        return MediaFileName(filename!, extension!);
      case ChanPostMediaType.THUMBNAIL:
        return MediaFileName("${imageId}s", ".jpg");
      case ChanPostMediaType.VIDEO_THUMBNAIL:
        return MediaFileName("${imageId}t", ".jpg");
    }
  }

  String getMediaUrl(ChanPostMediaType type) {
    if (imageId == null || extension == null) {
      throw Exception("Media URL is not available");
    }

    String targetImageId = "";
    String targetExtension = "";
    switch (type) {
      case ChanPostMediaType.MAIN:
        targetImageId = imageId!;
        targetExtension = extension!;
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
  }

  @override
  List<Object?> get props => [imageId, filename, extension, boardId, threadId, mediaId];
}

class MediaHelper {
  final ChanDownloader _chanDownloader;
  final ChanStorage _chanStorage;
  final ThumbnailHelper _thumbnailHelper;

  MediaHelper._(
    this._chanDownloader,
    this._chanStorage,
    this._thumbnailHelper,
  );

  static Future<MediaHelper> create(
    ChanStorage chanStorage,
    ChanDownloader chanDownloader,
    ThumbnailHelper thumbnailHelper,
  ) async {
    return MediaHelper._(chanDownloader, chanStorage, thumbnailHelper);
  }

  Future<ImageSource?> getThreadThumbnailSource(ThreadItem thread) async {
    if (!thread.hasMedia()) {
      return null;
    }

    final metadata = thread.getMediaMetadata();
    final mainUrl = metadata.getMediaUrl(ChanPostMediaType.MAIN);
    bool isDownloaded = await _chanDownloader.isMediaDownloaded(metadata);
    if (isDownloaded && metadata.isImageOrGif) {
      String filePath = _chanStorage
          .getMediaFile(
            metadata.getFileName(ChanPostMediaType.MAIN),
            metadata.cacheDirective,
          )!
          .path;
      return FileImageSource(mainUrl, filePath, metadata);
    }

    if (thread.isFavorite() && metadata.isWebm && isDownloaded) {
      File? thumbnailFile = _thumbnailHelper.getVideoThumbnail(metadata);
      if (thumbnailFile != null) {
        return FileImageSource(mainUrl, thumbnailFile.path, metadata);
      }
    }

    if (metadata.isWebm) {
      return NetworkImageSource(
        metadata.getMediaUrl(ChanPostMediaType.THUMBNAIL),
        null,
        metadata,
      );
    } else {
      return NetworkImageSource(
        metadata.getMediaUrl(ChanPostMediaType.MAIN),
        metadata.getMediaUrl(ChanPostMediaType.THUMBNAIL),
        metadata,
      );
    }
  }

  Future<MediaSource?> getMediaSource(PostItem post) async {
    final metadata = post.getMediaMetadata();
    if (metadata.isImageOrGif) {
      return await getImageSource(post);
    } else if (metadata.isWebm) {
      return await getVideoSource(post);
    } else {
      return null;
    }
  }

  Future<ImageSource> getImageSource(PostItem post) async {
    final metadata = post.getMediaMetadata();
    final mainUrl = metadata.getMediaUrl(ChanPostMediaType.MAIN);
    final downloaded = await _chanDownloader.isMediaDownloaded(metadata);
    if (downloaded && metadata.isImageOrGif) {
      String filePath = _chanStorage
          .getMediaFile(
            metadata.getFileName(ChanPostMediaType.MAIN),
            metadata.cacheDirective,
          )!
          .path;
      return FileImageSource(mainUrl, filePath, metadata);
    }

    if (post.isFavorite() && metadata.isWebm && downloaded) {
      File? thumbnailFile = _thumbnailHelper.getVideoThumbnail(metadata);
      if (thumbnailFile != null) {
        return FileImageSource(mainUrl, thumbnailFile.path, metadata);
      }
    }

    return NetworkImageSource(
      mainUrl,
      metadata.getMediaUrl(ChanPostMediaType.THUMBNAIL),
      metadata,
    );
  }

  Future<VideoSource> getVideoSource(PostItem post) async {
    final metadata = post.getMediaMetadata();
    ImageSource placeholderImage = await _getVideoThumbnailSource(post);
    final downloaded = await _chanDownloader.isMediaDownloaded(metadata);

    if (downloaded) {
      String filePath = _chanStorage
          .getMediaFile(
            metadata.getFileName(ChanPostMediaType.MAIN),
            metadata.cacheDirective,
          )!
          .path;
      return FileVideoSource(filePath, metadata, placeholderImage);
    }

    return NetworkVideoSource(metadata.getMediaUrl(ChanPostMediaType.MAIN), metadata, placeholderImage);
  }

  Future<ImageSource> _getVideoThumbnailSource(PostItem post) async {
    final metadata = post.getMediaMetadata();
    final mainUrl = metadata.getMediaUrl(ChanPostMediaType.MAIN);
    final videoThumbnailDownloaded = await _chanStorage.mediaFileExists(
      metadata.getFileName(ChanPostMediaType.VIDEO_THUMBNAIL),
      metadata.cacheDirective,
    );
    if (videoThumbnailDownloaded) {
      String filePath = _chanStorage
          .getMediaFile(
            metadata.getFileName(ChanPostMediaType.VIDEO_THUMBNAIL),
            metadata.cacheDirective,
          )!
          .path;
      return FileImageSource(mainUrl, filePath, metadata);
    }

    final thumbnailDownloaded = await _chanStorage.mediaFileExists(
      metadata.getFileName(ChanPostMediaType.THUMBNAIL),
      metadata.cacheDirective,
    );
    if (thumbnailDownloaded) {
      String filePath = _chanStorage
          .getMediaFile(
            metadata.getFileName(ChanPostMediaType.THUMBNAIL),
            metadata.cacheDirective,
          )!
          .path;
      return FileImageSource(mainUrl, filePath, metadata);
    } else {
      return NetworkImageSource(
        metadata.getMediaUrl(ChanPostMediaType.THUMBNAIL),
        null,
        metadata,
      );
    }
  }
}

@immutable
sealed class MediaSource extends Equatable {
  final MediaMetadata metadata;

  get boardId => metadata.boardId;

  get threadId => metadata.threadId;

  get mediaId => metadata.mediaId;

  get hasLocalFile => this is FileImageSource || this is FileVideoSource;

  MediaSource(
    this.metadata,
  );

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

  @override
  List<Object?> get props => [metadata];
}

@immutable
sealed class ImageSource extends MediaSource {
  final String mainUrl;

  ImageSource(
    this.mainUrl,
    MediaMetadata metadata,
  ) : super(metadata);

  @override
  List<Object?> get props => super.props..addAll([mainUrl]);
}

@immutable
class NetworkImageSource extends ImageSource {
  final String? thumbnailUrl;

  NetworkImageSource(
    String mainUrl,
    this.thumbnailUrl,
    MediaMetadata metadata,
  ) : super(mainUrl, metadata);

  @override
  List<Object?> get props => super.props..addAll([thumbnailUrl]);
}

@immutable
class FileImageSource extends ImageSource {
  final String filePath;

  FileImageSource(
    String mainUrl,
    this.filePath,
    MediaMetadata metadata,
  ) : super(mainUrl, metadata);

  @override
  List<Object?> get props => super.props..addAll([filePath]);
}

@immutable
sealed class VideoSource extends MediaSource {
  final ImageSource placeholderSource;

  VideoSource(
    this.placeholderSource,
    MediaMetadata metadata,
  ) : super(metadata);

  @override
  List<Object?> get props => super.props..addAll([placeholderSource]);
}

@immutable
class NetworkVideoSource extends VideoSource {
  final String url;

  NetworkVideoSource(
    this.url,
    MediaMetadata metadata,
    ImageSource placeholderImage,
  ) : super(placeholderImage, metadata);

  @override
  List<Object?> get props => super.props..addAll([url]);
}

@immutable
class FileVideoSource extends VideoSource {
  final String filePath;

  FileVideoSource(
    this.filePath,
    MediaMetadata metadata,
    ImageSource placeholderImage,
  ) : super(placeholderImage, metadata);

  @override
  List<Object?> get props => super.props..addAll([filePath]);
}

extension PostItemMediaExtension on PostItem {
  MediaMetadata getMediaMetadata() => MediaMetadata(
        imageId: imageId,
        filename: filename,
        extension: extension,
        boardId: boardId,
        threadId: threadId,
        mediaId: postId,
      );
}

extension ThreadItemMediaExtension on ThreadItem {
  MediaMetadata getMediaMetadata() => MediaMetadata(
        imageId: imageId,
        filename: filename,
        extension: extension,
        boardId: boardId,
        threadId: threadId,
        mediaId: threadId,
      );
}
