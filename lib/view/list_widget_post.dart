import 'package:flutter/material.dart';
import 'package:flutter_chan_viewer/models/ui/post_item_vo.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/extensions.dart';
import 'package:flutter_chan_viewer/utils/media_helper.dart';
import 'package:flutter_chan_viewer/view/view_cached_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class PostListWidget extends StatefulWidget {
  final PostItemVO post;
  final bool selected;
  final bool showImage;
  final bool showHeroAnimation;
  final Function onTap;
  final Function? onLongPress;
  final Function(String url) onLinkTap;

  @override
  _PostListWidgetState createState() => _PostListWidgetState();

  const PostListWidget({
    required this.post,
    required this.selected,
    required this.showImage,
    required this.showHeroAnimation,
    required this.onTap,
    required this.onLongPress,
    required this.onLinkTap,
  });
}

class _PostListWidgetState extends State<PostListWidget> with SingleTickerProviderStateMixin {
  AnimationController? _bounceController;
  late Animation<double> _bounceAnimation;

  initState() {
    super.initState();

    _bounceController = AnimationController(duration: const Duration(milliseconds: 5000), vsync: this, value: 1.0);
    _bounceAnimation = CurvedAnimation(parent: _bounceController!, curve: Curves.bounceInOut);

    if (widget.selected) {
      _bounceController!.forward(from: 0.5);
    }
  }

  @override
  dispose() {
    _bounceController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget card = ScaleTransition(
      scale: _bounceAnimation,
      child: buildContent(
        context,
        widget.post.mediaSource,
        widget.post.postId,
        widget.post.replies,
        widget.post.timestamp,
        widget.post.subtitle,
        widget.post.htmlContent,
      ),
    );

    return InkWell(
      onTap: widget.onTap as void Function()?,
      onLongPress: widget.onLongPress as void Function()?,
      child: widget.selected
          ? Shimmer(
              child: card,
              duration: Duration(seconds: 3),
            )
          : card,
    );
  }

  Widget buildContent(
    BuildContext context,
    MediaSource? mediaSource,
    int postId,
    int replies,
    int timestamp,
    String? subtitle,
    String? htmlContent,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.all(2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (widget.showImage && mediaSource != null)
            ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Constants.avatarImageSize,
                  minWidth: Constants.avatarImageSize,
                  minHeight: Constants.avatarImageSize,
                ),
                child: widget.showHeroAnimation
                    ? Hero(
                        tag: mediaSource.postId,
                        child: ChanCachedImage(imageSource: mediaSource.asImageSource(), boxFit: BoxFit.fitWidth))
                    : ChanCachedImage(imageSource: mediaSource.asImageSource(), boxFit: BoxFit.fitWidth)),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(postId.toString(), style: Theme.of(context).textTheme.caption),
                      Text("${replies}r", style: Theme.of(context).textTheme.caption),
                      Text(ChanUtil.getHumanDate(timestamp), style: Theme.of(context).textTheme.caption),
                    ],
                  ),
                  if (subtitle.isNotNullNorEmpty) Text(subtitle!, style: Theme.of(context).textTheme.bodyText1),
                  if (htmlContent.isNotNullNorEmpty)
                    Html(
                      data: ChanUtil.getReadableHtml(htmlContent, false),
                      style: {"*": Style(margin: Margins.zero)},
                      onLinkTap: (url, attributes, element) {
                        widget.onLinkTap(url!);
                      },
                      // onLinkTap: widget.onLinkTap,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
