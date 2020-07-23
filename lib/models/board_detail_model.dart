import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/models/local/threads_table.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';

class BoardDetailModel extends Equatable {
  final List<ThreadItem> _threads = [];

  BoardDetailModel.fromJson(String boardId, OnlineState onlineState, List<dynamic> parsedJson) {
    for (Map<String, dynamic> page in parsedJson) {
      for (Map<String, dynamic> thread in page['threads'] ?? []) {
        _threads.add(ThreadItem.fromMappedJson(boardId, null, onlineState, thread));
      }
    }
  }

  List<ThreadItem> get threads => _threads;

  @override
  List<Object> get props => [_threads];
}
