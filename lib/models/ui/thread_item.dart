import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chan_viewer/data/local/moor_db.dart';
import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';
import 'package:flutter_chan_viewer/models/local/threads_table.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';

class ThreadItem extends ChanPostBase with EquatableMixin {
  final OnlineState onlineStatus;
  final int replies;
  final int images;
  final int selectedPostId;
  final int unreadRepliesCount;
  final bool isThreadFavorite;

  @override
  bool isFavorite() => isThreadFavorite;

  ThreadItem({
    @required boardId,
    @required threadId,
    @required timestamp,
    subtitle = "",
    content = "",
    filename = "",
    imageId = "",
    extension = "",
    this.onlineStatus = OnlineState.UNKNOWN,
    this.isThreadFavorite = false,
    this.replies = 0,
    this.images = 0,
    this.selectedPostId = -1,
    this.unreadRepliesCount = 0,
  }) : super(
          boardId: boardId,
          threadId: threadId,
          timestamp: timestamp,
          subtitle: subtitle,
          content: content,
          filename: filename,
          imageId: imageId,
          extension: extension,
        );

  factory ThreadItem.fromMappedJson(
    String boardId,
    int threadId,
    OnlineState onlineState,
    Map<String, dynamic> json,
  ) =>
      ThreadItem(
        boardId: json['board_id'] ?? boardId,
        threadId: json['no'] ?? threadId,
        timestamp: json['time'],
        subtitle: ChanUtil.unescapeHtml(json['sub']),
        content: ChanUtil.unescapeHtml(json['com']),
        filename: json['filename'],
        imageId: json['tim'].toString(),
        extension: json['ext'],
        onlineStatus: onlineState,
        replies: json['replies'],
        images: json['images'],
      );

  factory ThreadItem.fromCacheDirective(CacheDirective cacheDirective) => ThreadItem(
        boardId: cacheDirective.boardId,
        threadId: cacheDirective.threadId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        onlineStatus: OnlineState.NOT_FOUND,
      );

  ThreadItem copyWithPostData(List<PostItem> posts) {
    PostItem firstPost = posts.first;
    int replies = this.replies ?? posts.length;
    int images = this.images ?? posts.where((post) => post.hasMedia()).length;
    return ThreadItem(
      boardId: this.boardId,
      threadId: this.threadId,
      timestamp: firstPost.timestamp,
      subtitle: firstPost.subtitle,
      content: firstPost.content,
      filename: firstPost.filename,
      imageId: firstPost.imageId,
      extension: firstPost.extension,
      onlineStatus: this.onlineStatus,
      isThreadFavorite: this.isThreadFavorite,
      replies: replies,
      images: images,
    );
  }

  ThreadsTableData toTableData() => ThreadsTableData(
        boardId: this.boardId,
        threadId: this.threadId,
        timestamp: this.timestamp,
        subtitle: this.subtitle,
        content: this.content,
        filename: this.filename,
        imageId: this.imageId,
        extension: this.extension,
        onlineState: this.onlineStatus,
        selectedPostId: this.selectedPostId,
        isFavorite: this.isThreadFavorite,
        replyCount: this.replies,
        imageCount: this.images,
        unreadRepliesCount: this.unreadRepliesCount,
      );

  factory ThreadItem.fromTableData(ThreadsTableData entry) => ThreadItem(
        boardId: entry.boardId,
        threadId: entry.threadId,
        timestamp: entry.timestamp,
        subtitle: entry.subtitle,
        content: entry.content,
        filename: entry.filename,
        imageId: entry.imageId,
        extension: entry.extension,
        onlineStatus: entry.onlineState,
        selectedPostId: entry.selectedPostId,
        isThreadFavorite: entry.isFavorite,
        replies: entry.replyCount,
        images: entry.imageCount,
        unreadRepliesCount: entry.unreadRepliesCount,
      );

  ThreadItem copyWith({
    OnlineState onlineStatus,
    int selectedPostId,
    int replies,
    int images,
    int unreadRepliesCount,
    bool isThreadFavorite,
    String boardId,
    int threadId,
    int timestamp,
    String subtitle,
    String content,
    String filename,
    String imageId,
    String extension,
  }) {
    return new ThreadItem(
      onlineStatus: onlineStatus ?? this.onlineStatus,
      selectedPostId: selectedPostId ?? this.selectedPostId,
      replies: replies ?? this.replies,
      images: images ?? this.images,
      unreadRepliesCount: unreadRepliesCount ?? this.unreadRepliesCount,
      isThreadFavorite: isThreadFavorite ?? this.isThreadFavorite,
      boardId: boardId ?? this.boardId,
      threadId: threadId ?? this.threadId,
      timestamp: timestamp ?? this.timestamp,
      subtitle: subtitle ?? this.subtitle,
      content: content ?? this.content,
      filename: filename ?? this.filename,
      imageId: imageId ?? this.imageId,
      extension: extension ?? this.extension,
    );
  }

  @override
  List<Object> get props => super.props + [onlineStatus, selectedPostId, isThreadFavorite, replies, images, unreadRepliesCount];
}
