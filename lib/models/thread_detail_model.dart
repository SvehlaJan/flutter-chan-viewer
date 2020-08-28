import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/models/local/threads_table.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:kt_dart/kt.dart';

class ThreadDetailModel with EquatableMixin {
  final ThreadItem _thread;
  final List<PostItem> _posts;
  int _selectedPostId;

  ThreadDetailModel._(this._thread, this._posts, this._selectedPostId);

  factory ThreadDetailModel.fromJson(String boardId, int threadId, OnlineState onlineState, Map<String, dynamic> parsedJson) {
    List<PostItem> posts = [];
    Map<int, PostItem> postMap = {};

    ThreadItem thread = ThreadItem.fromMappedJson(boardId, threadId, onlineState, parsedJson);

    for (Map<String, dynamic> postData in parsedJson['posts']) {
      PostItem newPost = PostItem.fromMappedJson(thread, postData);

      posts.add(newPost);
      postMap[newPost.postId] = newPost;

      for (int replyTo in newPost.repliesTo) {
        if (postMap.containsKey(replyTo)) {
          postMap[replyTo].repliesFrom.add(newPost);
        }
      }
    }

    if (posts.isNotEmpty) {
      thread = thread.copyWithPostData(posts.first);
    }

    int selectedPost = parsedJson['selected_post'] ?? -1;

    return ThreadDetailModel._(thread, posts, selectedPost);
  }

  factory ThreadDetailModel.fromFolderInfo(DownloadFolderInfo folderInfo) {
    List<PostItem> posts = [];
    folderInfo.fileNames.asMap().forEach((index, fileName) => posts.add(PostItem.fromDownloadedFile(fileName, folderInfo.cacheDirective, index)));
    return ThreadDetailModel._(ThreadItem.fromCacheDirective(folderInfo.cacheDirective), posts, 0);
  }

  factory ThreadDetailModel.fromCacheDirective(CacheDirective cacheDirective) {
    return ThreadDetailModel._(ThreadItem.fromCacheDirective(cacheDirective), [], 0);
  }

  factory ThreadDetailModel.fromThreadAndPosts(ThreadItem thread, List<PostItem> posts) {
    posts.forEach((post) => post.thread = thread);
    return ThreadDetailModel._(thread, posts, -1);
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

  ThreadItem get thread => _thread;

  List<PostItem> get posts => _posts;

  List<PostItem> get mediaPosts => _posts.where((post) => post.hasMedia()).toList();

  PostItem get firstPost => _posts?.first;

  int getPostIndex(int postId) => ((postId ?? -1) >= 0) ? _posts.indexWhere((post) => post.postId == postId) : -1;

  int getMediaIndex(int postId) => ((postId ?? -1) >= 0) ? mediaPosts.indexWhere((post) => post.postId == postId) : -1;

  PostItem findPostById(int postId) => _posts.where((post) => post.postId == postId)?.first;

  get selectedPostIndex => getPostIndex(_selectedPostId);

  set selectedPostIndex(int postIndex) => _selectedPostId = postIndex < posts.length ? posts[postIndex].postId : throw IndexOutOfBoundsException();

  get selectedMediaIndex => getMediaIndex(_selectedPostId);

  set selectedMediaIndex(int mediaIndex) =>
      _selectedPostId = mediaIndex < mediaPosts.length ? mediaPosts[mediaIndex].postId : throw IndexOutOfBoundsException();

  get selectedPostId => _selectedPostId;

  set selectedPostId(int postId) => _selectedPostId = getPostIndex(postId) >= 0 ? postId : throw IndexOutOfBoundsException();

  Map<String, dynamic> toJson() {
    return {..._thread.toJson(), 'posts': _posts.map((post) => post.toJson()).toList(), 'selected_post': _selectedPostId};
  }

  @override
  List<Object> get props => [_thread, _posts, _selectedPostId];
}
