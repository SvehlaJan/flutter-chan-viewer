import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/models/board_detail_model.dart';
import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';
import 'package:kt_dart/kt.dart';

class ThreadDetailModel {
  final ChanThread _thread;
  final List<ChanPost> _posts = [];
  int _selectedPost;

  ThreadDetailModel.fromJson(String boardId, int threadId, Map<String, dynamic> parsedJson)
      : _thread = ChanThread.fromMappedJson(boardId, parsedJson),
        _selectedPost = parsedJson['selected_post'] ?? 0 {
    for (Map<String, dynamic> post in parsedJson['posts']) {
      _posts.add(ChanPost.fromMappedJson(boardId, threadId, post));
    }
  }

  ChanThread get thread => _thread;

  List<ChanPost> get posts => _posts;

  List<ChanPost> get mediaPosts => _posts.where((post) => post.hasMedia()).toList();

  int getPostIndex(int postId) => (postId > 0) ? _posts.indexWhere((post) => post.postId == postId) : -1;

  int getMediaIndex(int postId) => (postId > 0) ? mediaPosts.indexWhere((post) => post.postId == postId) : -1;

  get selectedPostIndex => getPostIndex(_selectedPost);

  get selectedMediaIndex => getMediaIndex(_selectedPost);

  set selectedMediaIndex(int mediaIndex) => _selectedPost = mediaIndex < mediaPosts.length ? mediaPosts[mediaIndex].postId : throw IndexOutOfBoundsException();

  set selectedPostId(int postId) => _selectedPost = getPostIndex(postId) >= 0 ? postId : throw IndexOutOfBoundsException();

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
        'selected_post': _selectedPost
      };
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
