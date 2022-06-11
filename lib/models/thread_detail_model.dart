import 'package:collection/src/iterable_extensions.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/models/helper/online_state.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';

class ThreadDetailModel extends Equatable {
  final ThreadItem thread;
  final List<PostItem> _posts;

  ThreadDetailModel({
    required ThreadItem thread,
    required List<PostItem> posts,
  })  : thread = thread,
        _posts = posts;

  factory ThreadDetailModel.fromJson(
    String boardId,
    int threadId,
    OnlineState onlineState,
    Map<String, dynamic> parsedJson,
  ) {
    List<Map<String, dynamic>> allPosts =
        (parsedJson['posts'] as List).cast<Map<String, dynamic>>();

    ThreadItem thread = ThreadItem.fromMappedJson(
      boardId: boardId,
      threadId: threadId,
      onlineState: onlineState,
      lastModified: allPosts.last["time"],
      json: allPosts.first,
    );

    List<PostItem> posts = [];
    for (Map<String, dynamic> postData in allPosts) {
      posts.add(PostItem.fromMappedJson(thread, postData));
    }

    _calculateReplies(posts);

    return ThreadDetailModel(thread: thread, posts: posts);
  }

  factory ThreadDetailModel.fromFolderInfo(DownloadFolderInfo folderInfo) {
    List<PostItem> posts = [];
    folderInfo.fileNames.asMap().forEach((index, fileName) => posts.add(
        PostItem.fromDownloadedFile(
            fileName, folderInfo.cacheDirective, index)));
    return ThreadDetailModel(
        thread: ThreadItem.fromCacheDirective(folderInfo.cacheDirective),
        posts: posts);
  }

  factory ThreadDetailModel.fromCacheDirective(CacheDirective cacheDirective) {
    return ThreadDetailModel(
        thread: ThreadItem.fromCacheDirective(cacheDirective), posts: []);
  }

  factory ThreadDetailModel.fromThreadAndPosts(
      ThreadItem thread, List<PostItem> posts) {
    posts.forEach((post) => post.thread = thread);
    _calculateReplies(posts);
    return ThreadDetailModel(thread: thread, posts: posts);
  }

  ThreadDetailModel copyWith({
    ThreadItem? thread,
    List<PostItem>? posts,
  }) {
    return new ThreadDetailModel(
      thread: thread ?? this.thread,
      posts: posts ?? this._posts,
    );
  }

  static void _calculateReplies(List<PostItem> posts) {
    Map<int?, PostItem> postMap = {};
    for (PostItem post in posts) {
      postMap[post.postId] = post;

      for (int replyTo in post.repliesTo) {
        if (postMap.containsKey(replyTo)) {
          postMap[replyTo]!.repliesFrom.add(post);
        }
      }
    }
  }

  CacheDirective get cacheDirective => thread.getCacheDirective();

  List<PostItem> get visiblePosts =>
      _posts.where((post) => !post.isHidden).toList();

  List<PostItem> get hiddenPosts =>
      _posts.where((post) => post.isHidden).toList();

  List<PostItem> get allPosts => _posts;

  List<PostItem> get visibleMediaPosts =>
      _posts.where((post) => post.hasMedia() && !post.isHidden).toList();

  List<PostItem> get allMediaPosts =>
      _posts.where((post) => post.hasMedia()).toList();

  PostItem? findPostById(int? postId) {
    return _posts.where((post) => post.postId == postId).firstOrNull;
  }

  int get selectedPostId {
    return thread.selectedPostId;
  }

  int get selectedPostIndex {
    return _posts.indexWhere((post) => post.postId == selectedPostId);
  }

  int get selectedMediaIndex {
    return findPostsMediaIndex(selectedPostId);
  }

  PostItem? get selectedPost {
    return _posts.where((post) => post.postId == selectedPostId).firstOrNull;
  }

  bool get isFavorite => thread.isFavorite();

  int findPostsMediaIndex(int postId) {
    return allMediaPosts.indexWhere((post) => post.postId == postId);
  }

  @override
  List<Object?> get props => [thread, _posts];
}
