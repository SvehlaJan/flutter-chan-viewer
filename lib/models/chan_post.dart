import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:path/path.dart';

class ChanPost extends ChanPostBase with EquatableMixin {
  final int postId;
  final List<int> repliesTo;
  final List<ChanPost> repliesFrom = [];

  bool get hasReplies => repliesFrom.isNotEmpty;

  factory ChanPost.fromMappedJson(String boardId, int threadId, Map<String, dynamic> json) => ChanPost(
        json['board_id'] ?? boardId,
        json['thread_id'] ?? threadId,
        json['no'],
        json['time'],
        ChanUtil.unescapeHtml(json['sub']),
        ChanUtil.unescapeHtml(json['com']),
        json['filename'],
        json['tim'].toString(),
        json['ext'],
        ChanUtil.getPostReferences(json['com']),
      );

  factory ChanPost.fromDownloadedFile(String fileName, CacheDirective cacheDirective, int postId) {
    String imageId = basenameWithoutExtension(fileName);
    String extensionStr = extension(fileName);
    return ChanPost(
      cacheDirective.boardId,
      cacheDirective.threadId,
      postId,
      0,
      "",
      "",
      fileName,
      imageId,
      extensionStr,
      [],
    );
  }

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

  ChanPost(String boardId, int threadId, this.postId, int timestamp, String subtitle, String content, String filename, String imageId, String extension, this.repliesTo)
      : super(
          boardId,
          threadId,
          timestamp,
          subtitle,
          content,
          filename,
          imageId,
          extension,
        );

  @override
  List<Object> get props => super.props + [postId];
}
