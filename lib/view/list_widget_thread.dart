import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/view/view_cached_image.dart';
import 'package:flutter_html/flutter_html.dart';

class ThreadListWidget extends StatelessWidget {
  final ThreadItem thread;
  final bool showProgress;

  const ThreadListWidget({
    @required this.thread,
    @required this.showProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.all(2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (thread.hasMedia())
            ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Constants.avatarImageSize,
                  minWidth: Constants.avatarImageSize,
                  minHeight: Constants.avatarImageSize,
//                  maxHeight: Constants.avatarImageMaxHeight,
                ),
                child: ChanCachedImage(post: thread, boxFit: BoxFit.fitWidth, forceThumbnail: true)),
          Flexible(
            fit: FlexFit.tight,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          if (thread?.isFavorite() ?? false)
                            Padding(padding: const EdgeInsets.all(1.0), child: Icon(Icons.star, color: Colors.yellow, size: Constants.favoriteIconSize)),
                          Text(thread.threadId.toString(), style: Theme.of(context).textTheme.caption),
                          Spacer(),
                          Text("${thread.replies ?? "?"}p/${thread.images ?? "?"}m", style: Theme.of(context).textTheme.caption),
                          Spacer(),
                          Text(ChanUtil.getHumanDate(thread.timestamp), style: Theme.of(context).textTheme.caption),
                        ],
                      ),
                      if (thread.subtitle != null) Text(thread.subtitle, style: Theme.of(context).textTheme.subtitle),
                      Html(
                        data: ChanUtil.getReadableHtml(thread.content ?? "", true),
                        onLinkTap: ((String url) {
                          ChanLogger.d("Html link clicked { url: $url }");
                        }),
                      )
                    ],
                  ),
                ),
                if (showProgress) LinearProgressIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
