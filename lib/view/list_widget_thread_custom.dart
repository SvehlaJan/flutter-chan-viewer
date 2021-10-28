import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/utils/extensions.dart';

class CustomThreadListWidget extends StatelessWidget {
  final ThreadItem thread;

  const CustomThreadListWidget({
    required this.thread,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (thread.subtitle.isNotNullNorEmpty)
              Text(thread.subtitle!,
                  style: Theme.of(context).textTheme.headline6, maxLines: 2)
          ],
        ),
      ),
    );
  }
}
