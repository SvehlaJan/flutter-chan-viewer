import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chan_viewer/models/board_list_model.dart';

class BoardListWidget extends StatelessWidget {
  final ChanBoard board;

  const BoardListWidget({
    @required this.board,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(board.title, style: Theme.of(context).textTheme.title),
            if (!board.workSafe) Text(" !!!", style: Theme.of(context).textTheme.title.copyWith(color: Theme.of(context).errorColor)),
          ],
        ),
      ),
    );
  }
}
