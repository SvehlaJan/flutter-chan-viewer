import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chan_viewer/models/board_list_model.dart';

class BoardListWidget extends StatelessWidget {
  final ChanBoard _board;

  BoardListWidget(this._board);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(_board.title, style: Theme.of(context).textTheme.title,)
          ],
        ),
      ),
    );
  }
}
