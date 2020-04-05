import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/models/chan_post.dart';
import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';

class BoardDetailModel extends Equatable {
  final List<ChanThread> _threads = [];

  BoardDetailModel.fromJson(String boardId, List<dynamic> parsedJson) {
    for (Map<String, dynamic> page in parsedJson) {
      for (Map<String, dynamic> thread in page['threads'] ?? []) {
        _threads.add(ChanThread.fromMappedJson(boardId, null, thread));
      }
    }
  }

  List<ChanThread> get threads => _threads;

  @override
  List<Object> get props => [_threads];
}

class ChanThread extends ChanPostBase with EquatableMixin {
  int replies;
  int images;

  ChanThread(
      String boardId, int threadId, int timestamp, String subtitle, String content, String filename, String imageId, String extension, bool isFavorite, this.replies, this.images)
      : super(
          boardId,
          threadId,
          timestamp,
          subtitle,
          content,
          filename,
          imageId,
          extension,
          isFavorite,
        );

  factory ChanThread.fromMappedJson(String boardId, int threadId, Map<String, dynamic> json) => ChanThread(
        json['board_id'] ?? boardId,
        json['no'] ?? threadId,
        json['time'],
        ChanUtil.unescapeHtml(json['sub']),
        ChanUtil.unescapeHtml(json['com']),
        json['filename'],
        json['tim'].toString(),
        json['ext'],
        json['is_favorite'] ?? json['isFavorite'] ?? false,
        json['replies'],
        json['images'],
      );

  factory ChanThread.fromCacheDirective(CacheDirective cacheDirective) => ChanThread(
        cacheDirective.boardId,
        cacheDirective.threadId,
        0,
        "",
        "",
        "",
        "",
        "",
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
        'is_favorite': isFavorite,
      };

  @override
  List<Object> get props => super.props;

  ChanThread copyWithPostData(ChanPost post) =>
      ChanThread(boardId, threadId, post.timestamp, post.subtitle, post.content, post.filename, post.imageId, post.extension, isFavorite, replies, images);
}
