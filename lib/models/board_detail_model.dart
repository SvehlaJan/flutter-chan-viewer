import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/models/local/threads_table.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';

class BoardDetailModel extends Equatable {
  final List<ThreadItem> _threads;

  BoardDetailModel(this._threads);

  factory BoardDetailModel.fromJson(String boardId, OnlineState onlineState, List<int> favoriteThreadIds, List<dynamic> parsedJson) {
    List<ThreadItem> threads = [];
    for (Map<String, dynamic> page in parsedJson) {
      for (Map<String, dynamic> thread in page['threads'] ?? []) {
        bool isFavorite = favoriteThreadIds.contains(thread['no']);
        threads.add(ThreadItem.fromMappedJson(boardId, null, onlineState, isFavorite, thread));
      }
    }
    return BoardDetailModel(threads);
  }

  factory BoardDetailModel.withThreads(List<ThreadItem> threads) {
    return BoardDetailModel(threads);
  }

  List<ThreadItem> get threads => _threads;

  @override
  List<Object> get props => [_threads];
}
