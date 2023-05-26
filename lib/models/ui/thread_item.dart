import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chan_viewer/data/local/moor_db.dart';
import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';
import 'package:flutter_chan_viewer/models/helper/online_state.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/utils/media_helper.dart';

@immutable
class ThreadItem extends ChanPostBase with EquatableMixin {
  final int onlineStatus;
  final int? lastModified;
  final int replies;
  final int images;
  final int selectedPostId;
  final int lastSeenPostIndex;
  final bool isThreadFavorite;

  @override
  bool isFavorite() => isThreadFavorite;

  ImageSource getThumbnailImageSource() => MediaHelper.getThreadThumbnailSource(this);

  ThreadItem({
    required boardId,
    required threadId,
    timestamp,
    subtitle = "",
    htmlContent = "",
    filename = "",
    imageId = "",
    extension = "",
    this.onlineStatus = 0, // OnlineState.ONLINE
    this.lastModified = 0,
    this.isThreadFavorite = false,
    this.replies = 0,
    this.images = 0,
    this.selectedPostId = -1,
    this.lastSeenPostIndex = 0,
  }) : super(
          boardId: boardId,
          threadId: threadId,
          timestamp: timestamp,
          subtitle: subtitle,
          htmlContent: htmlContent,
          filename: filename,
          imageId: imageId,
          extension: extension,
        );

  factory ThreadItem.fromMappedJson({
    required String? boardId,
    required int? threadId,
    required OnlineState onlineState,
    required int lastModified,
    required Map<String, dynamic> json,
  }) =>
      ThreadItem(
        boardId: json['board_id'] ?? boardId,
        threadId: json['no'] ?? threadId,
        timestamp: json['time'],
        lastModified: json['last_modified'] ?? lastModified,
        subtitle: ChanUtil.unescapeHtml(json['sub']),
        htmlContent: ChanUtil.unescapeHtml(json['com']),
        filename: json['filename'],
        imageId: json['tim'].toString(),
        extension: json['ext'],
        onlineStatus: onlineState.index,
        replies: json['replies'],
        images: json['images'],
      );

  factory ThreadItem.fromCacheDirective(CacheDirective cacheDirective) => ThreadItem(
        boardId: cacheDirective.boardId,
        threadId: cacheDirective.threadId,
        timestamp: ChanUtil.getNowTimestamp(),
        lastModified: ChanUtil.getNowTimestamp(),
        onlineStatus: OnlineState.NOT_FOUND.index,
      );

  ThreadsTableData toTableData() => ThreadsTableData(
        boardId: this.boardId,
        threadId: this.threadId,
        timestamp: this.timestamp,
        subtitle: this.subtitle,
        content: this.htmlContent,
        filename: this.filename,
        imageId: this.imageId,
        extension: this.extension,
        onlineState: this.onlineStatus,
        lastModified: this.lastModified,
        selectedPostId: this.selectedPostId,
        isFavorite: this.isThreadFavorite,
        replyCount: this.replies,
        imageCount: this.images,
        lastSeenPostIndex: this.lastSeenPostIndex,
      );

  factory ThreadItem.fromTableData(ThreadsTableData entry) => ThreadItem(
        boardId: entry.boardId,
        threadId: entry.threadId,
        timestamp: entry.timestamp,
        subtitle: entry.subtitle,
        htmlContent: entry.content,
        filename: entry.filename,
        imageId: entry.imageId,
        extension: entry.extension,
        onlineStatus: entry.onlineState ?? 0,
        lastModified: entry.lastModified,
        selectedPostId: entry.selectedPostId ?? -1,
        isThreadFavorite: entry.isFavorite ?? false,
        replies: entry.replyCount ?? -1,
        images: entry.imageCount ?? -1,
        lastSeenPostIndex: entry.lastSeenPostIndex ?? 0,
      );

  ThreadItem copyWith({
    int? onlineStatus,
    int? lastModified,
    int? selectedPostId,
    int? replies,
    int? images,
    int? lastSeenPostIndex,
    bool? isThreadFavorite,
    String? boardId,
    int? threadId,
    int? timestamp,
    String? subtitle,
    String? htmlContent,
    String? filename,
    String? imageId,
    String? extension,
  }) {
    return new ThreadItem(
      onlineStatus: onlineStatus ?? this.onlineStatus,
      lastModified: lastModified ?? this.lastModified,
      selectedPostId: selectedPostId ?? this.selectedPostId,
      replies: replies ?? this.replies,
      images: images ?? this.images,
      lastSeenPostIndex: lastSeenPostIndex ?? this.lastSeenPostIndex,
      isThreadFavorite: isThreadFavorite ?? this.isThreadFavorite,
      boardId: boardId ?? this.boardId,
      threadId: threadId ?? this.threadId,
      timestamp: timestamp ?? this.timestamp,
      subtitle: subtitle ?? this.subtitle,
      htmlContent: htmlContent ?? this.htmlContent,
      filename: filename ?? this.filename,
      imageId: imageId ?? this.imageId,
      extension: extension ?? this.extension,
    );
  }

  @override
  List<Object?> get props =>
      super.props + [onlineStatus, lastModified, selectedPostId, isThreadFavorite, replies, images, lastSeenPostIndex];
}
