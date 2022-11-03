import 'package:flutter/material.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/view/view_cached_image.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class PostGridWidget extends StatefulWidget {
  final PostItem post;
  final bool selected;
  final Function onTap;
  final Function onLongPress;

  const PostGridWidget({
    key,
    required this.post,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  _PostGridWidgetState createState() => _PostGridWidgetState();
}

class _PostGridWidgetState extends State<PostGridWidget> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  late Animation<double> _animation;

  initState() {
    super.initState();

    _controller = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this, value: 1.0);
    _animation = CurvedAnimation(parent: _controller!, curve: Curves.bounceInOut);
    if (widget.selected) {
      _controller!.forward(from: 0.5);
    }
  }

  @override
  dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = buildContent(context);
    return GridTile(
      child: InkWell(
        onTap: widget.onTap as void Function()?,
        onLongPress: widget.onLongPress as void Function()?,
        child: ScaleTransition(
          scale: _animation,
          child: widget.selected
              ? Shimmer(
                  child: content,
                  duration: Duration(seconds: 3),
                )
              : content,
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    final bool _isDownloaded = getIt<ChanRepository>().isMediaDownloaded(widget.post);
    return Card(
      margin: EdgeInsets.all(1.0),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          Hero(tag: widget.post.getMediaUrl()!, child: ChanCachedImage(post: widget.post, boxFit: BoxFit.cover)),
          if (_isDownloaded) Align(alignment: Alignment.bottomRight, child: Icon(Icons.sd_storage)),
          if (widget.post.isGif()) Align(alignment: Alignment.bottomLeft, child: Icon(Icons.gif)),
          if (widget.post.isWebm()) Align(alignment: Alignment.bottomRight, child: Icon(Icons.play_arrow)),
        ],
      ),
    );
  }
}
