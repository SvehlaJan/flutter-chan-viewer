import 'package:equatable/equatable.dart';

class ArchiveListModel extends Equatable {
  final List<int> _threads;

  ArchiveListModel(this._threads);

  factory ArchiveListModel.fromJson(String? boardId, List<dynamic> parsedJson) {
    List<int> threads = [];
    parsedJson.forEach((element) {
      threads.add(element);
    });

    return ArchiveListModel(threads);
  }

  List<int> get threads => _threads;

  @override
  List<Object> get props => [_threads];
}
