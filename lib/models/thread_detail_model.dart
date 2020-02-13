import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/models/board_detail_model.dart';
import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:kt_dart/kt.dart';
import 'package:path/path.dart';

class ThreadDetailModel with EquatableMixin {
  final ChanThread _thread;
  final List<ChanPost> _posts;
  int _selectedPostId;

  ThreadDetailModel._(this._thread, this._posts, this._selectedPostId);

  factory ThreadDetailModel.fromJson(String boardId, int threadId, Map<String, dynamic> parsedJson) {
    List<ChanPost> posts = [];
    for (Map<String, dynamic> post in parsedJson['posts']) {
      posts.add(ChanPost.fromMappedJson(boardId, threadId, post));
    }
    ChanThread thread = ChanThread.fromMappedJson(boardId, threadId, parsedJson);
    if (posts.isNotEmpty) thread = thread.copyWithPostData(posts.first);

    int selectedPost = parsedJson['selected_post'] ?? 0;

    return new ThreadDetailModel._(thread, posts, selectedPost);
  }

  factory ThreadDetailModel.fromFolderInfo(DownloadFolderInfo folderInfo) {
    List<ChanPost> posts = [];
    folderInfo.fileNames.asMap().forEach((index, fileName) => posts.add(ChanPost.fromDownloadedFile(fileName, folderInfo.cacheDirective, index)));
    return new ThreadDetailModel._(ChanThread.fromCacheDirective(folderInfo.cacheDirective), posts, 0);
  }

  /*
  ThreadDetailModel.fromJson(String boardId, int threadId, Map<String, dynamic> parsedJson)
      : _thread = ChanThread.fromMappedJson(boardId, threadId, parsedJson),
        _selectedPost = parsedJson['selected_post'] ?? 0 {
    for (Map<String, dynamic> post in parsedJson['posts']) {
      _posts.add(ChanPost.fromMappedJson(boardId, threadId, post));
    }
  }

  static ThreadDetailModel fromJson(String boardId, int threadId, Map<String, dynamic> parsedJson) {
    List<ChanPost> posts = [];
    for (Map<String, dynamic> post in parsedJson['posts']) {
      posts.add(ChanPost.fromMappedJson(boardId, threadId, post));
    }

    ChanThread thread = ChanThread.fromMappedJson(boardId, threadId, parsedJson);
    if (posts.isNotEmpty) thread = thread.copyWithPostData(posts.first);

    int selectedPost = parsedJson['selected_post'] ?? 0;

    return new ThreadDetailModel._(thread, posts, selectedPost);
  }
  */

  CacheDirective get cacheDirective => _thread.getCacheDirective();

  String get cacheKey => cacheDirective.getCacheKey();

  ChanThread get thread => _thread;

  List<ChanPost> get posts => _posts;

  List<ChanPost> get mediaPosts => _posts.where((post) => post.hasMedia()).toList();

  int getPostIndex(int postId) => (postId > 0) ? _posts.indexWhere((post) => post.postId == postId) : -1;

  int getMediaIndex(int postId) => (postId > 0) ? mediaPosts.indexWhere((post) => post.postId == postId) : -1;

  get selectedPostIndex => getPostIndex(_selectedPostId);

  get selectedMediaIndex => getMediaIndex(_selectedPostId);

  set selectedMediaIndex(int mediaIndex) => _selectedPostId = mediaIndex < mediaPosts.length ? mediaPosts[mediaIndex].postId : throw IndexOutOfBoundsException();

  set selectedPostId(int postId) => _selectedPostId = getPostIndex(postId) >= 0 ? postId : throw IndexOutOfBoundsException();

  get selectedPostId => _selectedPostId;

  Map<String, dynamic> toJson() => {
        'board_id': _thread.boardId,
        'no': _thread.threadId,
        'time': _thread.timestamp,
        'sub': _thread.subtitle,
        'com': _thread.content,
        'filename': _thread.filename,
        'tim': _thread.imageId,
        'ext': _thread.extension,
        'is_favorite': _thread.isFavorite,
        'posts': _posts.map((post) => post.toJson()),
        'selected_post': _selectedPostId
      };

  @override
  List<Object> get props => [_thread, _posts, _selectedPostId];
}

class ChanPost extends ChanPostBase with EquatableMixin {
  final int postId;
  final List<ChanPost> replies;

  factory ChanPost.fromMappedJson(String boardId, int threadId, Map<String, dynamic> json) => ChanPost(
      json['board_id'] ?? boardId, json['thread_id'] ?? threadId, json['no'], json['time'], json['sub'], json['com'], json['filename'], json['tim'].toString(), json['ext'], []);

  factory ChanPost.fromDownloadedFile(String fileName, CacheDirective cacheDirective, int postId) {
    String imageId = basenameWithoutExtension(fileName);
    String extensionStr = extension(fileName);
    return ChanPost(cacheDirective.boardId, cacheDirective.threadId, postId, 0, "", "", fileName, imageId, extensionStr, []);
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

  ChanPost(String boardId, int threadId, this.postId, int timestamp, String subtitle, String content, String filename, String imageId, String extension, this.replies)
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
