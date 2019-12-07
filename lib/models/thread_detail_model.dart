import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/models/board_detail_model.dart';
import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';
import 'package:kt_dart/kt.dart';

class ThreadDetailModel with EquatableMixin {
  final ChanThread _thread;
  final List<ChanPost> _posts;
  int _selectedPostId;

  ThreadDetailModel._(this._thread, this._posts, this._selectedPostId);

//  factory (String boardId, int threadId, Map<String, dynamic> parsedJson) {
//    ChanThread thread = ChanThread.fromMappedJson(boardId, threadId, parsedJson);
//    List<ChanPost> posts = [];
//    for (Map<String, dynamic> post in parsedJson['posts']) {
//      posts.add(ChanPost.fromMappedJson(boardId, threadId, post));
//    }
//    int selectedPost = parsedJson['selected_post'] ?? 0;
//    return new ThreadDetailModel._(thread, posts, selectedPost);
//  }

//  ThreadDetailModel.fromJson(String boardId, int threadId, Map<String, dynamic> parsedJson)
//      : _thread = ChanThread.fromMappedJson(boardId, threadId, parsedJson),
//        _selectedPost = parsedJson['selected_post'] ?? 0 {
//    for (Map<String, dynamic> post in parsedJson['posts']) {
//      _posts.add(ChanPost.fromMappedJson(boardId, threadId, post));
//    }
//  }

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
        'posts': _posts,
        'selected_post': _selectedPostId
      };

  @override
  List<Object> get props => [_thread, _posts, _selectedPostId];
}

class ChanPost extends ChanPostBase with EquatableMixin {
  final int postId;

  factory ChanPost.fromMappedJson(String boardId, int threadId, Map<String, dynamic> json) =>
      ChanPost(json['boardId'] ?? boardId, json['threadId'] ?? threadId, json['no'], json['time'], json['sub'], json['com'], json['filename'], json['tim'].toString(), json['ext']);

  Map<String, dynamic> toJson() =>
      {'board_id': boardId, 'thread_id': threadId, 'no': postId, 'time': timestamp, 'sub': subtitle, 'com': content, 'filename': filename, 'tim': imageId, 'ext': extension};

  ChanPost(String boardId, int threadId, this.postId, int timestamp, String subtitle, String content, String filename, String imageId, String extension)
      : super(boardId, threadId, timestamp, subtitle, content, filename, imageId, extension);

  @override
  List<Object> get props => super.props + [postId];
}
