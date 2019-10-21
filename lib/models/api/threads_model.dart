import 'package:equatable/equatable.dart';

import 'posts_model.dart';

class ThreadsModel extends Equatable {
  final List<ChanThread> _threads = [];

  ThreadsModel.fromJson(String boardId, Map<String, dynamic> parsedJson) {
    for (Map<String, dynamic> thread in parsedJson['threads']) {
      List<ChanPost> posts = [];
      for (Map<String, dynamic> post in thread['posts'] ?? []) {
        posts.add(ChanPost.fromJson(boardId, post));
      }
      _threads.add(ChanThread(posts.first?.postId, posts.first?.date, posts.first?.content, posts));
    }
  }

  List<ChanThread> get threads => _threads;
}

class ChanThread extends Equatable {
  final int threadId;
  final String date;
  final String content;
  final List<ChanPost> posts;

  ChanThread(this.threadId, this.date, this.content, this.posts)
      : super([
          threadId,
          date,
          content,
          posts
        ]);

  String getThumbnailUrl() => posts.first?.getThumbnailUrl();
}
