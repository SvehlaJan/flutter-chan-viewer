import 'package:equatable/equatable.dart';

class BoardListModel {
  final List<ChanBoard> _boards = [];

  BoardListModel.fromJson(Map<String, dynamic> parsedJson) {
    for (Map<String, dynamic> board in parsedJson['boards']) {
      _boards.add(ChanBoard(board['board'], board['title']));
    }
  }

  List<ChanBoard> get boards => _boards;
}

class ChanBoard extends Equatable {
  final String boardId;
  final String title;

  ChanBoard(this.boardId, this.title)
      : super([
          boardId,
          title
        ]);
}
