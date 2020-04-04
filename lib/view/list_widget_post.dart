import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chan_viewer/models/chan_post.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/extensions.dart';
import 'package:flutter_chan_viewer/view/view_cached_image.dart';
import 'package:flutter_html/flutter_html.dart';

class PostListWidget extends StatefulWidget {
  final ChanPost post;
  final bool selected;
  final bool showAsHeader;
  final bool showHeroAnimation;
  final Function onTap;
  final Function(String url) onLinkTap;

  @override
  _PostListWidgetState createState() => _PostListWidgetState();

  const PostListWidget({
    @required this.post,
    this.selected = false,
    this.showAsHeader = false,
    this.showHeroAnimation = true,
    this.onTap,
    this.onLinkTap,
  });
}

class _PostListWidgetState extends State<PostListWidget> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  initState() {
    super.initState();

    if (widget.selected) {
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
      onTap: widget.onTap,
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
          if (!widget.showAsHeader && widget.post.getThumbnailUrl() != null)
            ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Constants.avatarImageSize,
                  minWidth: Constants.avatarImageSize,
                  minHeight: Constants.avatarImageSize,
                ),
                child: widget.showHeroAnimation
                    ? Hero(tag: widget.post.getMediaUrl(), child: ChanCachedImage(post: widget.post, boxFit: BoxFit.fitWidth))
                    : ChanCachedImage(post: widget.post, boxFit: BoxFit.fitWidth)),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(widget.post.postId.toString(), style: Theme.of(context).textTheme.caption),
                      Text("${widget.post.repliesFrom.length}r", style: Theme.of(context).textTheme.caption),
                      Text(ChanUtil.getHumanDate(widget.post.timestamp), style: Theme.of(context).textTheme.caption),
                    ],
                  ),
                  if (widget.post.subtitle.isNotNullNorEmpty) Text(widget.post.subtitle, style: Theme.of(context).textTheme.bodyText1),
                  if (widget.post.content.isNotNullNorEmpty) Html(data: ChanUtil.getReadableHtml(widget.post.content, false), onLinkTap: widget.onLinkTap),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
