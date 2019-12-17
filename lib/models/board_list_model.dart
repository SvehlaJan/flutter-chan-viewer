import 'package:equatable/equatable.dart';

class BoardListModel extends Equatable {
  final List<ChanBoard> _boards;

  BoardListModel(this._boards);

  factory BoardListModel.fromJson(Map<String, dynamic> parsedJson) {
    List<ChanBoard> boards = [];
    for (Map<String, dynamic> board in parsedJson['boards']) {
      boards.add(ChanBoard.fromMappedJson(board));
    }
    return BoardListModel(boards);
  }

  List<ChanBoard> get boards => _boards;

  @override
  List<Object> get props => [_boards];
}

// ignore: must_be_immutable
class ChanBoard extends Equatable {
  final String boardId;
  final String title;
  final int _workSafe;

  bool get workSafe => _workSafe == 1;

  ChanBoard(this.boardId, this.title, this._workSafe);

  factory ChanBoard.fromMappedJson(Map<String, dynamic> json) => ChanBoard(
        json['board'],
        json['title'],
        json['ws_board'],
      );

  Map<String, dynamic> toJson() => {
        'board': boardId,
        'title': title,
        'ws_board': _workSafe,
      };

  @override
  List<Object> get props => [boardId, title, workSafe];
}
