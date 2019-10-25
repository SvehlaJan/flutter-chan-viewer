import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chan_viewer/models/api/catalog_model.dart';
import 'package:flutter_chan_viewer/models/api/threads_model.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/view/view_cached_image.dart';
import 'package:flutter_html/flutter_html.dart';

class CatalogThreadListWidget extends StatelessWidget {
  final ChanCatalogThread _thread;

  CatalogThreadListWidget(this._thread);

  @override
  Widget build(BuildContext context) {
    String imageUrl = _thread.getThumbnailUrl();
    print("Building ThreadListWidget { Thread: $_thread }");
    return Card(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: Constants.avatarImageSize),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (imageUrl != null) ConstrainedBox(constraints: BoxConstraints(maxWidth: Constants.avatarImageSize), child: ChanCachedImage(imageUrl)),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(_thread.threadId.toString(), style: Theme.of(context).textTheme.caption),
                        Text(_thread.date, style: Theme.of(context).textTheme.caption),
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    ),
                    Html(data: ChanUtil.getHtml(_thread.content ?? ""))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
