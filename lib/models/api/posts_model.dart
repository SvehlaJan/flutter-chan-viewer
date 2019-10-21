import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/api/chan_api_provider.dart';

class PostsModel {
  final List<ChanPost> _posts = [];

  PostsModel.fromJson(String boardId, Map<String, dynamic> parsedJson) {
    for (Map<String, dynamic> post in parsedJson['posts']) {
      _posts.add(ChanPost.fromJson(boardId, post));
    }
  }

  List<ChanPost> get posts => _posts;
}

class ChanPost extends Equatable {
  final String boardId;
  final int postId;
  final String date;
  final String content;
  final String filename;
  final String imageId;
  final String extension;

  static ChanPost fromJson(String boardId, Map<String, dynamic> json) {
    return ChanPost(boardId, json['no'], json['now'], json['com'], json['filename'], json['tim'].toString(), json['ext']);
  }

  ChanPost(this.boardId, this.postId, this.date, this.content, this.filename, this.imageId, this.extension)
      : super([
          boardId,
          postId,
          date,
          content,
          filename,
          imageId,
          extension
        ]);

  bool hasImage() => [
        ".jpg",
        ".png",
        ".gif",
        ".webp"
      ].contains(extension);

  String getImageUrl() => ChanApiProvider.getImageUrl(this, false);
  String getThumbnailUrl() => ChanApiProvider.getImageUrl(this, true);
}
