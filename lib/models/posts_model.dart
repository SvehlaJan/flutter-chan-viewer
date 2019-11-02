import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/models/helper/chan_image.dart';

class PostsModel {
  final List<ChanPost> _posts = [];

  PostsModel.fromJson(String boardId, Map<String, dynamic> parsedJson) {
    for (Map<String, dynamic> post in parsedJson['posts']) {
      _posts.add(ChanPost.fromMappedJson(boardId, post));
    }
  }

  List<ChanPost> get posts => _posts;

  List<ChanPost> get mediaPosts => _posts.where((post) => post.hasMedia()).toList();

  int getPostIndex(int postId) => _posts.indexWhere((post) => post.postId == postId);

  int getMediaIndex(int postId) => mediaPosts.indexWhere((post) => post.postId == postId);
}

class ChanPost extends ChanImage with EquatableMixin {
  final String boardId;
  final int postId;
  final int timestamp;
  final String content;

  factory ChanPost.fromMappedJson(String boardId, Map<String, dynamic> json) =>
      ChanPost(json['boardId'] ?? boardId, json['no'], json['time'], json['com'], json['filename'], json['tim'].toString(), json['ext']);

  Map<String, dynamic> toJson() => {
    'board_id': boardId,
    'time': timestamp,
    'com': content,
    'filename': filename,
    'tim': imageId,
    'ext': extension
  };

  ChanPost(this.boardId, this.postId, this.timestamp, this.content, String filename, String imageId, String extension) : super(filename, imageId, extension);

  @override
  List<Object> get props => [boardId, postId, timestamp, content, filename, imageId, extension];
}
