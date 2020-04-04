import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/models/board_detail_model.dart';
import 'package:flutter_chan_viewer/models/chan_post.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:kt_dart/kt.dart';

class ThreadDetailModel with EquatableMixin {
  final ChanThread _thread;
  final List<ChanPost> _posts;
  int _selectedPostId;
  OnlineState onlineStatus;

  ThreadDetailModel._(this._thread, this._posts, this._selectedPostId, this.onlineStatus);

  factory ThreadDetailModel.fromJson(String boardId, int threadId, Map<String, dynamic> parsedJson, OnlineState isLive) {
    List<ChanPost> posts = [];
    Map<int, ChanPost> postMap = {};
    for (Map<String, dynamic> postData in parsedJson['posts']) {
      ChanPost newPost = ChanPost.fromMappedJson(boardId, threadId, postData);

      posts.add(newPost);
      postMap[newPost.postId] = newPost;

      for (int replyTo in newPost.repliesTo) {
        if (postMap.containsKey(replyTo)) {
          postMap[replyTo].repliesFrom.add(newPost);
        }
      }
    }
    ChanThread thread = ChanThread.fromMappedJson(boardId, threadId, parsedJson);
    if (posts.isNotEmpty) thread = thread.copyWithPostData(posts.first);

    int selectedPost = parsedJson['selected_post'] ?? 0;

    return ThreadDetailModel._(thread, posts, selectedPost, isLive);
  }

  factory ThreadDetailModel.fromFolderInfo(DownloadFolderInfo folderInfo) {
    List<ChanPost> posts = [];
    folderInfo.fileNames.asMap().forEach((index, fileName) => posts.add(ChanPost.fromDownloadedFile(fileName, folderInfo.cacheDirective, index)));
    return ThreadDetailModel._(ChanThread.fromCacheDirective(folderInfo.cacheDirective), posts, 0, OnlineState.OFFLINE);
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

  ChanPost get firstPost => _posts?.first;

  int getPostIndex(int postId) => ((postId ?? -1) >= 0) ? _posts.indexWhere((post) => post.postId == postId) : -1;

  int getMediaIndex(int postId) => ((postId ?? -1) >= 0) ? mediaPosts.indexWhere((post) => post.postId == postId) : -1;

  ChanPost findPostById(int postId) => _posts.where((post) => post.postId == postId)?.first;

  get selectedPostIndex => getPostIndex(_selectedPostId);

  set selectedPostIndex(int postIndex) => _selectedPostId = postIndex < posts.length ? posts[postIndex].postId : throw IndexOutOfBoundsException();

  get selectedMediaIndex => getMediaIndex(_selectedPostId);

  set selectedMediaIndex(int mediaIndex) => _selectedPostId = mediaIndex < mediaPosts.length ? mediaPosts[mediaIndex].postId : throw IndexOutOfBoundsException();

  get selectedPostId => _selectedPostId;

  set selectedPostId(int postId) => _selectedPostId = getPostIndex(postId) >= 0 ? postId : throw IndexOutOfBoundsException();

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
