import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chan_viewer/models/chan_post.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/view/view_cached_image.dart';
import 'package:flutter_html/flutter_html.dart';

class PostListWidget extends StatefulWidget {
  final ChanPost _post;
  final bool _selected;
  final Function _onTap;
  final Function(String url) _onLinkTap;

  PostListWidget(this._post, this._selected, this._onTap, this._onLinkTap);

  @override
  _PostListWidgetState createState() => _PostListWidgetState();
}

class _PostListWidgetState extends State<PostListWidget> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  initState() {
    super.initState();

    if (widget._selected) {
      _controller = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this, value: 0.6, lowerBound: 0.5);
      _animation = CurvedAnimation(parent: _controller, curve: Curves.bounceInOut);
      _controller.forward();
    }
  }

  @override
  dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget._onTap,
      child: buildContent(context),
    );
  }

  Widget buildContent(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.all(2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (widget._post.getThumbnailUrl() != null)
            ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Constants.avatarImageSize,
                  minWidth: Constants.avatarImageSize,
                  minHeight: Constants.avatarImageSize,
                ),
                child: Hero(tag: widget._post.getMediaUrl(), child: ChanCachedImage(widget._post, BoxFit.fitWidth))),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0, right: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(widget._post.postId.toString(), style: Theme.of(context).textTheme.caption),
                      Spacer(),
                      Text("${widget._post.repliesFrom.length}r", style: Theme.of(context).textTheme.caption),
                      Spacer(),
                      Text(ChanUtil.getHumanDate(widget._post.timestamp), style: Theme.of(context).textTheme.caption),
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                  if (widget._post.subtitle != null) Text(widget._post.subtitle, style: Theme.of(context).textTheme.subtitle),
                  Html(data: ChanUtil.getReadableHtml(widget._post.content ?? "", false), onLinkTap: widget._onLinkTap),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
