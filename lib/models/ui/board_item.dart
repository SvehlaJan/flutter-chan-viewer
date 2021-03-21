import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/data/local/moor_db.dart';

class BoardItem extends Equatable {
  final String boardId;
  final String title;
  final int _workSafe;

  bool get workSafe => _workSafe == 1;

  BoardItem(this.boardId, this.title, this._workSafe);

  factory BoardItem.fromMappedJson(Map<String, dynamic> json) => BoardItem(
        json['board'],
        json['title'],
        json['ws_board'],
      );

  Map<String, dynamic> toJson() => {
        'board': boardId,
        'title': title,
        'ws_board': _workSafe,
      };

  BoardsTableData toTableData() => BoardsTableData(
        boardId: boardId,
        title: title,
        workSafe: _workSafe == 1,
      );

  factory BoardItem.fromTableData(BoardsTableData entry) => BoardItem(
        entry.boardId,
        entry.title,
        entry.workSafe! ? 1 : 0,
      );

  @override
  List<Object?> get props => [boardId, title, workSafe];
}
