import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/data/local/moor_db.dart';
import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:path/path.dart';

class PostItem extends ChanPostBase with EquatableMixin {
  final int postId;
  final List<int> repliesTo;
  final List<PostItem> repliesFrom;
  final bool isHidden;
  ThreadItem? thread;

  bool get hasReplies => repliesFrom.isNotEmpty;
  List<PostItem> get visibleReplies =>
      repliesFrom.where((element) => element.isHidden == false).toList();

  PostItem({
    required boardId,
    required threadId,
    required timestamp,
    required subtitle,
    required htmlContent,
    required filename,
    required imageId,
    required extension,
    required this.postId,
    required this.repliesTo,
    required this.repliesFrom,
    this.isHidden = false,
    this.thread,
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

  @override
  bool isFavorite() => thread?.isFavorite() ?? false;

  factory PostItem.fromMappedJson(
          ThreadItem thread, Map<String, dynamic> json) =>
      PostItem(
        boardId: json['board_id'] ?? thread.boardId,
        threadId: json['thread_id'] ?? thread.threadId,
        postId: json['no'],
        timestamp: json['time'],
        subtitle: ChanUtil.unescapeHtml(json['sub']),
        htmlContent: ChanUtil.unescapeHtml(json['com']),
        filename: json['filename'],
        imageId: json['tim'].toString(),
        extension: json['ext'],
        repliesTo: ChanUtil.getPostReferences(json['com']),
        repliesFrom: [],
        thread: thread,
        isHidden: false,
      );

  factory PostItem.fromDownloadedFile(
      String fileName, CacheDirective cacheDirective, int postId) {
    String imageId = basenameWithoutExtension(fileName);
    String extensionStr = extension(fileName);
    return PostItem(
      boardId: cacheDirective.boardId,
      threadId: cacheDirective.threadId,
      postId: postId,
      timestamp: 0,
      subtitle: "",
      htmlContent: "",
      filename: fileName,
      imageId: imageId,
      extension: extensionStr,
      repliesTo: [],
      repliesFrom: [],
      thread: null,
      isHidden: false,
    );
  }

  PostsTableData toTableData() => PostsTableData(
        postId: this.postId,
        boardId: this.boardId,
        threadId: this.threadId,
        timestamp: this.timestamp,
        subtitle: this.subtitle,
        content: this.htmlContent,
        filename: this.filename,
        imageId: this.imageId,
        extension: this.extension,
        isHidden: this.isHidden,
      );

  factory PostItem.fromTableData(PostsTableData entry, {ThreadItem? thread}) =>
      PostItem(
        boardId: entry.boardId,
        threadId: entry.threadId,
        postId: entry.postId,
        timestamp: entry.timestamp,
        subtitle: entry.subtitle,
        htmlContent: entry.content,
        filename: entry.filename,
        imageId: entry.imageId,
        extension: entry.extension,
        repliesTo: ChanUtil.getPostReferences(entry.content),
        isHidden: entry.isHidden ?? false,
        repliesFrom: [],
        thread: thread,
      );

  PostItem copyWith({
    int? postId,
    List<int>? repliesTo,
    List<PostItem>? repliesFrom,
    bool? isHidden,
    ThreadItem? thread,
    String? boardId,
    int? threadId,
    int? timestamp,
    String? subtitle,
    String? htmlContent,
    String? filename,
    String? imageId,
    String? extension,
  }) {
    return new PostItem(
      postId: postId ?? this.postId,
      repliesTo: repliesTo ?? this.repliesTo,
      repliesFrom: repliesFrom ?? this.repliesFrom,
      isHidden: isHidden ?? this.isHidden,
      thread: thread ?? this.thread,
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
      super.props + [postId, repliesTo, repliesFrom, thread, isHidden];
}
