import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/data/local/moor_db.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';
import 'package:path/path.dart';

class PostItem extends ChanPostBase with EquatableMixin {
  final int postId;
  final List<int> repliesTo;
  final List<PostItem> repliesFrom = [];

  bool get hasReplies => repliesFrom.isNotEmpty;

  factory PostItem.fromMappedJson(String boardId, int threadId, Map<String, dynamic> json) => PostItem(
        json['board_id'] ?? boardId,
        json['thread_id'] ?? threadId,
        json['no'],
        json['time'],
        ChanUtil.unescapeHtml(json['sub']),
        ChanUtil.unescapeHtml(json['com']),
        json['filename'],
        json['tim'].toString(),
        json['ext'],
        false,
        ChanUtil.getPostReferences(json['com']),
      );

  factory PostItem.fromDownloadedFile(String fileName, CacheDirective cacheDirective, int postId) {
    String imageId = basenameWithoutExtension(fileName);
    String extensionStr = extension(fileName);
    return PostItem(
      cacheDirective.boardId,
      cacheDirective.threadId,
      postId,
      0,
      "",
      "",
      fileName,
      imageId,
      extensionStr,
      false,
      [],
    );
  }

  PostsTableData toTableData() => PostsTableData(
      postId: this.postId,
      boardId: this.boardId,
      threadId: this.threadId,
      timestamp: this.timestamp,
      subtitle: this.subtitle,
      content: this.content,
      filename: this.filename,
      imageId: this.imageId,
      extension: this.extension,
      isFavorite: this.isFavorite);

  factory PostItem.fromTableData(PostsTableData entry) => PostItem(
        entry.boardId,
        entry.threadId,
        entry.postId,
        entry.timestamp,
        entry.subtitle,
        entry.content,
        entry.filename,
        entry.imageId,
        entry.extension,
        entry.isFavorite,
        ChanUtil.getPostReferences(entry.content),
      );

  Map<String, dynamic> toJson() => {
        'board_id': this.boardId,
        'thread_id': this.threadId,
        'no': this.postId,
        'time': this.timestamp,
        'sub': this.subtitle,
        'com': this.content,
        'filename': this.filename,
        'tim': this.imageId,
        'ext': this.extension,
      };

  PostItem(
      String boardId, int threadId, this.postId, int timestamp, String subtitle, String content, String filename, String imageId, String extension, bool isFavorite, this.repliesTo)
      : super(boardId, threadId, timestamp, subtitle, content, filename, imageId, extension, isFavorite);

  @override
  List<Object> get props => super.props + [postId];
}
