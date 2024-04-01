import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chan_viewer/locator.dart';
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
  final int downloadProgress;

  PostItemVO(
    this.mediaSource,
    this.postId,
    this.replies,
    this.timestamp,
    this.subtitle,
    this.htmlContent,
    this.downloadProgress,
  );

  @override
  List<Object?> get props => [mediaSource, postId, replies, timestamp, subtitle, htmlContent, downloadProgress];
}

extension PostItemExtension on PostItem {
  Future<PostItemVO> toPostItemVO(MediaHelper mediaHelper) async {
    return PostItemVO(
      await mediaHelper.getMediaSource(this),
      postId,
      repliesTo.length,
      timestamp,
      subtitle,
      htmlContent,
      downloadProgress,
    );
  }
}

extension PostItemListExtension on List<PostItem> {
  Future<List<PostItemVO>> toPostItemVOList(MediaHelper mediaHelper) async {
    return Future.wait(map((e) => e.toPostItemVO(mediaHelper)));
  }
}
