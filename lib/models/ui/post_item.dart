import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chan_viewer/data/local/moor_db.dart';
import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/utils/download_helper.dart';
import 'package:flutter_chan_viewer/utils/media_helper.dart';
import 'package:path/path.dart';

@immutable
class PostItem extends ChanPostBase with EquatableMixin {
  final int postId;
  final List<int> repliesTo;
  final bool isHidden;
  final ThreadItem? thread;

  PostItem({
    required boardId,
    required threadId,
    required timestamp,
    required subtitle,
    required htmlContent,
    required filename,
    required imageId,
    required extension,
    required downloadProgress,
    required this.postId,
    required this.repliesTo,
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
          downloadProgress: downloadProgress,
        );

  @override
  bool isFavorite() => thread?.isFavorite() ?? false;

  ImageSource getThumbnailImageSource() => MediaHelper.getImageSource(this, true);

  factory PostItem.fromMappedJson(ThreadItem thread, Map<String, dynamic> json) {
    dynamic boardId = json['board_id'] ?? thread.boardId;
    dynamic threadId = json['thread_id'] ?? thread.threadId;
    dynamic postId = json['no'];
    return PostItem(
      boardId: boardId,
      threadId: threadId,
      postId: postId,
      timestamp: json['time'],
      subtitle: ChanUtil.unescapeHtml(json['sub']),
      htmlContent: ChanUtil.unescapeHtml(json['com']),
      filename: json['filename'],
      imageId: json['tim'].toString(),
      extension: json['ext'],
      downloadProgress: ChanDownloadProgress.NOT_STARTED.value,
      repliesTo: ChanUtil.getPostReferences(json['com']),
      thread: thread,
    );
  }

  factory PostItem.fromDownloadedFile(String fileName, CacheDirective cacheDirective, int postId) {
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
      downloadProgress: ChanDownloadProgress.FINISHED.value,
      repliesTo: [],
      thread: null,
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
        downloadProgress: this.downloadProgress,
        isHidden: this.isHidden,
      );

  factory PostItem.fromTableData(PostsTableData entry, {ThreadItem? thread}) => PostItem(
        boardId: entry.boardId,
        threadId: entry.threadId,
        postId: entry.postId,
        timestamp: entry.timestamp,
        subtitle: entry.subtitle,
        htmlContent: entry.content,
        filename: entry.filename,
        imageId: entry.imageId,
        extension: entry.extension,
        downloadProgress: entry.downloadProgress,
        repliesTo: ChanUtil.getPostReferences(entry.content),
        isHidden: entry.isHidden ?? false,
        thread: thread,
      );

  PostItem copyWith({
    int? postId,
    List<int>? repliesTo,
    bool? isHidden,
    int? progress,
    ThreadItem? thread,
    String? boardId,
    int? threadId,
    int? timestamp,
    String? subtitle,
    String? htmlContent,
    String? filename,
    String? imageId,
    String? extension,
    int? downloadProgress,
  }) {
    return new PostItem(
      postId: postId ?? this.postId,
      repliesTo: repliesTo ?? this.repliesTo,
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
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }

  @override
  List<Object?> get props => super.props + [postId, repliesTo, thread, isHidden];
}
