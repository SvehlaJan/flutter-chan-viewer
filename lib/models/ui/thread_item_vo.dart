import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/utils/media_helper.dart';

@immutable
class ThreadItemVO with EquatableMixin {
  final int threadId;
  final String boardId; // TODO - get rid of this
  final int timestamp;
  final String? subtitle;
  final String? htmlContent;
  final int onlineStatus;
  final MediaSource? mediaSource;
  final int replies;
  final int images;
  final int selectedPostId;
  final int lastSeenPostIndex;
  final bool isFavorite;

  ThreadItemVO(
    this.threadId,
    this.boardId,
    this.timestamp,
    this.subtitle,
    this.htmlContent,
    this.onlineStatus,
    this.mediaSource,
    this.replies,
    this.images,
    this.selectedPostId,
    this.lastSeenPostIndex,
    this.isFavorite,
  );

  String? get content => ChanUtil.getPlainString(htmlContent);

  @override
  List<Object?> get props => [
        threadId,
        boardId,
        timestamp,
        subtitle,
        htmlContent,
        onlineStatus,
        mediaSource,
        replies,
        images,
        selectedPostId,
        lastSeenPostIndex,
        isFavorite
      ];
}

extension ThreadItemVOExtension on ThreadItem {
  ThreadItemVO toThreadItemVO() {
    return ThreadItemVO(
      threadId,
      boardId,
      timestamp,
      subtitle,
      htmlContent,
      onlineStatus,
      MediaHelper.getThreadThumbnailSource(this),
      replies,
      images,
      selectedPostId,
      lastSeenPostIndex,
      isThreadFavorite,
    );
  }
}
