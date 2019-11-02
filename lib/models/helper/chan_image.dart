import 'package:flutter_chan_viewer/api/chan_api_provider.dart';

abstract class ChanImage {
  final String filename;
  final String imageId;
  final String extension;

  ChanImage(this.filename, this.imageId, this.extension);

  bool hasImage() => [".jpg", ".png", ".gif", ".webp"].contains(extension);

  bool hasVideo() => [".webm"].contains(extension);

  bool hasMedia() => hasImage() || hasVideo();

  String getMediaUrl() => ChanApiProvider.getPostMediaUrl(this, false);

  String getThumbnailUrl() => ChanApiProvider.getPostMediaUrl(this, true);
}