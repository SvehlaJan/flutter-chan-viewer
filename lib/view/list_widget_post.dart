import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chan_viewer/models/posts_model.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/view/view_cached_image.dart';
import 'package:flutter_html/flutter_html.dart';

class PostListWidget extends StatelessWidget {
  final ChanPost _post;

  PostListWidget(this._post);

  @override
  Widget build(BuildContext context) {
    print("Building PostListWidget { Post: $_post }");
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.all(2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (_post.getThumbnailUrl() != null)
            ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Constants.avatarImageSize,
                  minWidth: Constants.avatarImageSize,
                  minHeight: Constants.avatarImageSize,
                ),
                child: ChanCachedImage(_post)),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0, right: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(_post.postId.toString(), style: Theme.of(context).textTheme.caption),
                      Text(ChanUtil.getHumanDate(_post.timestamp), style: Theme.of(context).textTheme.caption),
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                  Html(data: ChanUtil.getHtml(_post.content ?? ""))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
