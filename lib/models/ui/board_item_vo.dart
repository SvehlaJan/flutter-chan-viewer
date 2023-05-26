import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chan_viewer/models/ui/board_item.dart';

@immutable
class BoardItemVO extends Equatable {
  final String boardId;
  final String title;
  final bool workSafe;

  BoardItemVO(this.boardId, this.title, this.workSafe);

  @override
  List<Object?> get props => [boardId, title, workSafe];
}

extension BoardItemVOExtension on BoardItem {
  BoardItemVO toBoardItemVO() {
    return BoardItemVO(
      boardId,
      title,
      workSafe,
    );
  }
}
