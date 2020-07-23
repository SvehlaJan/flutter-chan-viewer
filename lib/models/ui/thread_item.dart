import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/data/local/moor_db.dart';
import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';
import 'package:flutter_chan_viewer/models/local/threads_table.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';

class ThreadItem extends ChanPostBase with EquatableMixin {
  final OnlineState onlineStatus;
  final int replies;
  final int images;
  bool _isFavorite; // TODO - make final

  @override
  bool isFavorite() => _isFavorite;

  void setFavorite(bool isFavorite) => _isFavorite = isFavorite;

  ThreadItem(
    String boardId,
    int threadId,
    int timestamp,
    String subtitle,
    String content,
    String filename,
    String imageId,
    String extension,
    this.onlineStatus,
    this._isFavorite,
    this.replies,
    this.images,
  ) : super(
          boardId,
          threadId,
          timestamp,
          subtitle,
          content,
          filename,
          imageId,
          extension,
        );

  factory ThreadItem.fromMappedJson(String boardId, int threadId, OnlineState onlineState, Map<String, dynamic> json) => ThreadItem(
        json['board_id'] ?? boardId,
        json['no'] ?? threadId,
        json['time'],
        ChanUtil.unescapeHtml(json['sub']),
        ChanUtil.unescapeHtml(json['com']),
        json['filename'],
        json['tim'].toString(),
        json['ext'],
        onlineState,
        json['is_favorite'],
        json['replies'],
        json['images'],
      );

  factory ThreadItem.fromCacheDirective(CacheDirective cacheDirective) => ThreadItem(
        cacheDirective.boardId,
        cacheDirective.threadId,
        0,
        "",
        "",
        "",
        "",
        "",
        OnlineState.NOT_FOUND,
        false,
        0,
        0,
      );

  Map<String, dynamic> toJson() => {
        'board_id': boardId,
        'no': threadId,
        'time': timestamp,
        'sub': subtitle,
        'com': content,
        'filename': filename,
        'tim': imageId,
        'ext': extension,
        'replies': replies,
        'images': images,
        'is_favorite': _isFavorite,
      };

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
        isFavorite: this._isFavorite,
        replyCount: this.replies,
        imageCount: this.images,
      );

  factory ThreadItem.fromTableData(ThreadsTableData entry) => ThreadItem(
        entry.boardId,
        entry.threadId,
        entry.timestamp,
        entry.subtitle,
        entry.content,
        entry.filename,
        entry.imageId,
        entry.extension,
        entry.onlineState,
        entry.isFavorite,
        entry.replyCount,
        entry.imageCount,
      );

  @override
  List<Object> get props => super.props + [onlineStatus, _isFavorite, replies, images];
}
