import 'package:equatable/equatable.dart';

class ArchiveListModel extends Equatable {
  final List<int> _threads;

  ArchiveListModel(this._threads);

  factory ArchiveListModel.fromJson(String boardId, List<dynamic> parsedJson) {
    List<int> threads = [];
    for (int threadId in parsedJson) {
      threads.add(threadId);
    }
    return ArchiveListModel(threads);
  }

  List<int> get threads => _threads;

  @override
  List<Object> get props => [_threads];
}