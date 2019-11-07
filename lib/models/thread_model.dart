import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';

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

class ChanThread extends ChanPostBase with EquatableMixin {

  ChanThread(String boardId, int threadId, int timestamp, String content, String filename, String imageId, String extension)
      : super(boardId, threadId, timestamp, content, filename, imageId, extension);

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

  @override
  List<Object> get props => super.props;
}
