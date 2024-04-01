import 'package:flutter/material.dart';
import 'package:flutter_chan_viewer/utils/media_helper.dart';
import 'package:flutter_chan_viewer/view/view_cached_image.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class GridWidgetMedia extends StatefulWidget {
  final MediaSource mediaSource;
  final bool selected;
  final Function onTap;
  final Function onLongPress;

  const GridWidgetMedia({
    key,
    required this.mediaSource,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  _GridWidgetMediaState createState() => _GridWidgetMediaState();
}

class _GridWidgetMediaState extends State<GridWidgetMedia> with SingleTickerProviderStateMixin {
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
    Widget content = buildContent(context, widget.mediaSource);
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

  Widget buildContent(BuildContext context, MediaSource mediaSource) {
    final metadata = mediaSource.metadata;
    final hasLocalFile = mediaSource.hasLocalFile;

    return Card(
      margin: EdgeInsets.all(1.0),
      clipBehavior: Clip.antiAlias,
      child: Hero(
        tag: metadata.mediaId,
        child: ChanCachedImage(imageSource: mediaSource.asImageSource(), boxFit: BoxFit.cover),
      ),
    );
  }
}
