import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/models/local/threads_table.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';

class BoardDetailModel extends Equatable {
  final List<ThreadItem> _threads;

  BoardDetailModel(this._threads);

  factory BoardDetailModel.fromJson(String boardId, OnlineState onlineState, List<dynamic> parsedJson) {
    List<ThreadItem> threads = [];
    for (Map<String, dynamic> page in parsedJson) {
      for (Map<String, dynamic> threadJson in page['threads'] ?? []) {
        threads.add(ThreadItem.fromMappedJson(
          boardId: boardId,
          threadId: null,
          onlineState: onlineState,
          lastModified: ChanUtil.getNowTimestamp(),
          json: threadJson,
        ));
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
