import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chan_viewer/models/ui/board_item.dart';

class BoardListWidget extends StatelessWidget {
  final BoardItem board;

  const BoardListWidget({
    required this.board,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(board.title, style: Theme.of(context).textTheme.headline6),
            if (!board.workSafe) Text(" !!!", style: Theme.of(context).textTheme.headline6!.copyWith(color: Theme.of(context).errorColor)),
          ],
        ),
      ),
    );
  }
}
