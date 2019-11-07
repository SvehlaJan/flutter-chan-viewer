import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';

class PostsModel {
  final List<ChanPost> _posts = [];

  PostsModel.fromJson(String boardId, int threadId, Map<String, dynamic> parsedJson) {
    for (Map<String, dynamic> post in parsedJson['posts']) {
      _posts.add(ChanPost.fromMappedJson(boardId, threadId, post));
    }
  }

  List<ChanPost> get posts => _posts;

  List<ChanPost> get mediaPosts => _posts.where((post) => post.hasMedia()).toList();

  int getPostIndex(int postId) => _posts.indexWhere((post) => post.postId == postId);

  int getMediaIndex(int postId) => mediaPosts.indexWhere((post) => post.postId == postId);
}

class ChanPost extends ChanPostBase with EquatableMixin {
  final int postId;

  factory ChanPost.fromMappedJson(String boardId, int threadId, Map<String, dynamic> json) =>
      ChanPost(json['boardId'] ?? boardId, json['threadId'] ?? threadId, json['no'], json['time'], json['com'], json['filename'], json['tim'].toString(), json['ext']);

  Map<String, dynamic> toJson() => {
    'board_id': boardId,
    'thread_id': threadId,
    'no': postId,
    'time': timestamp,
    'com': content,
    'filename': filename,
    'tim': imageId,
    'ext': extension
  };

  ChanPost(String boardId, int threadId, this.postId, int timestamp, String content, String filename, String imageId, String extension) : super(boardId, threadId, timestamp, content, filename, imageId, extension);

  @override
  List<Object> get props => super.props + [postId];

}
