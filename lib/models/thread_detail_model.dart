import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chan_viewer/models/local/threads_table.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';

class ThreadDetailModel with EquatableMixin {
  ThreadItem thread;
  final List<PostItem> _posts;

  ThreadDetailModel({
    @required ThreadItem thread,
    @required List<PostItem> posts,
  })  : thread = thread,
        _posts = posts;

  factory ThreadDetailModel.fromJson(
    String boardId,
    int threadId,
    OnlineState onlineState,
    Map<String, dynamic> parsedJson,
  ) {
    ThreadItem thread = ThreadItem.fromMappedJson(boardId, threadId, onlineState, parsedJson);

    List<PostItem> posts = [];
    for (Map<String, dynamic> postData in parsedJson['posts']) {
      posts.add(PostItem.fromMappedJson(thread, postData));
    }

    _calculateReplies(posts);

    if (posts.isNotEmpty) {
      thread = thread.copyWithPostData(posts);
    }

    return ThreadDetailModel(thread: thread, posts: posts);
  }

  factory ThreadDetailModel.fromFolderInfo(DownloadFolderInfo folderInfo) {
    List<PostItem> posts = [];
    folderInfo.fileNames.asMap().forEach((index, fileName) => posts.add(PostItem.fromDownloadedFile(fileName, folderInfo.cacheDirective, index)));
    return ThreadDetailModel(thread: ThreadItem.fromCacheDirective(folderInfo.cacheDirective), posts: posts);
  }

  factory ThreadDetailModel.fromCacheDirective(CacheDirective cacheDirective) {
    return ThreadDetailModel(thread: ThreadItem.fromCacheDirective(cacheDirective), posts: []);
  }

  factory ThreadDetailModel.fromThreadAndPosts(ThreadItem thread, List<PostItem> posts) {
    posts.forEach((post) => post.thread = thread);
    _calculateReplies(posts);
    return ThreadDetailModel(thread: thread, posts: posts);
  }

  ThreadDetailModel copyWith({
    ThreadItem thread,
    List<PostItem> posts,
  }) {
    return new ThreadDetailModel(
      thread: thread ?? this.thread,
      posts: posts ?? this._posts,
    );
  }

  static void _calculateReplies(List<PostItem> posts) {
    Map<int, PostItem> postMap = {};
    for (PostItem post in posts) {
      postMap[post.postId] = post;

      for (int replyTo in post.repliesTo) {
        if (postMap.containsKey(replyTo)) {
          postMap[replyTo].repliesFrom.add(post);
        }
      }
    }
  }

  CacheDirective get cacheDirective => thread.getCacheDirective();

  List<PostItem> get visiblePosts => _posts.where((post) => !post.isHidden).toList() ?? [];

  List<PostItem> get hiddenPosts => _posts.where((post) => post.isHidden).toList() ?? [];

  List<PostItem> get allPosts => _posts ?? [];

  List<PostItem> get visibleMediaPosts => _posts.where((post) => post.hasMedia() && !post.isHidden).toList();

  List<PostItem> get allMediaPosts => _posts.where((post) => post.hasMedia()).toList();

  int getPostIndex(int postId) => ((postId ?? -1) >= 0) ? _posts.indexWhere((post) => post.postId == postId) : -1;

  int getMediaIndex(int postId) => ((postId ?? -1) >= 0) ? allMediaPosts.indexWhere((post) => post.postId == postId) : -1;

  PostItem findPostById(int postId) => _posts.where((post) => post.postId == postId)?.first;

  int get selectedPostId => thread.selectedPostId ?? -1;

  int get selectedPostIndex => getPostIndex(selectedPostId);

  int get selectedMediaIndex => getMediaIndex(selectedPostId);

  PostItem get selectedPost => _posts.where((post) => post.postId == selectedPostId)?.first;

  @override
  List<Object> get props => [thread, _posts];
}
