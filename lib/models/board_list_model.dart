import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/models/ui/board_item.dart';

class BoardListModel extends Equatable {
  final List<BoardItem> _boards;

  BoardListModel(this._boards);

  factory BoardListModel.fromJson(Map<String, dynamic> parsedJson) {
    List<BoardItem> boards = [];
    for (Map<String, dynamic> board in parsedJson['boards']) {
      boards.add(BoardItem.fromMappedJson(board));
    }
    return BoardListModel(boards);
  }

  List<BoardItem> get boards => _boards;

  @override
  List<Object> get props => [_boards];
}
