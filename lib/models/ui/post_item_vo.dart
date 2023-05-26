import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chan_viewer/models/helper/media_type.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/utils/media_helper.dart';

@immutable
class PostItemVO with EquatableMixin {
  final MediaSource? mediaSource;
  final int postId;
  final int replies;
  final int timestamp;
  final String? subtitle;
  final String? htmlContent;
  final String? fileName;
  final int downloadProgress;
  final MediaType mediaType;

  PostItemVO(
    this.mediaSource,
    this.postId,
    this.replies,
    this.timestamp,
    this.subtitle,
    this.htmlContent,
    this.fileName,
    this.downloadProgress,
    this.mediaType,
  );

  @override
  List<Object?> get props =>
      [mediaSource, postId, replies, timestamp, subtitle, htmlContent, downloadProgress, mediaType];

  bool isDownloaded() => downloadProgress == 100;
}

extension PostItemVOExtension on PostItem {
  PostItemVO toPostItemVO() {
    return PostItemVO(
      MediaHelper.getMediaSource(this),
      postId,
      repliesTo.length,
      timestamp,
      subtitle,
      htmlContent,
      filename != null ? "${filename}${extension}" : null,
      downloadProgress,
      mediaType,
    );
  }
}
