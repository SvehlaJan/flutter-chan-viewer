import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';

class ArchiveThreadListWidget extends StatelessWidget {
  final ThreadItem thread;
  final bool isLoading;

  const ArchiveThreadListWidget({
    required this.thread,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(thread.threadId.toString(), style: Theme.of(context).textTheme.headline6),
            if (isLoading) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
