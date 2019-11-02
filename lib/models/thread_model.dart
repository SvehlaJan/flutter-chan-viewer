import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/api/chan_api_provider.dart';
import 'package:flutter_chan_viewer/models/posts_model.dart';

class ThreadsModel extends Equatable {
  final List<ChanThread> _threads = [];

  ThreadsModel.fromJson(String boardId, List<dynamic> parsedJson) {
    for (Map<String, dynamic> page in parsedJson) {
      for (Map<String, dynamic> thread in page['threads'] ?? []) {
        _threads.add(ChanThread.fromMappedJson(boardId, thread));
      }
    }
  }

  List<ChanThread> get threads => _threads;
}

class ChanThread extends Equatable {
  final String boardId;
  final int threadId;
//  final ChanPost firstPost;
  final int timestamp;
  final String content;
  final String filename;
  final String imageId;
  final String extension;

  ChanThread(this.boardId, this.threadId, this.timestamp, this.content, this.filename, this.imageId, this.extension)
      : super([boardId, threadId, timestamp, content, filename, imageId, extension]);

  factory ChanThread.fromMappedJson(String boardId, Map<String, dynamic> json) =>
      ChanThread(json['boardId'] ?? boardId, json['no'], json['time'], json['com'], json['filename'], json['tim'].toString(), json['ext']);

  Map<String, dynamic> toJson() => {
    'board_id': boardId,
    'no': threadId,
    'time': timestamp,
    'com': content,
    'filename': filename,
    'tim': imageId,
    'ext': extension
  };

  String getThumbnailUrl() => ChanApiProvider.getMediaUrl(this.boardId, this.imageId, this.extension, true);
}
