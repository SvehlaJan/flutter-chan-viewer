import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/models/chan_post.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/bloc/thread_detail_bloc.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/bloc/thread_detail_event.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/bloc/thread_detail_state.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/view/view_cached_image.dart';

class PostGridWidget extends StatefulWidget {
  final ChanPost _post;
  final bool _selected;
  final Function _onTap;

  PostGridWidget(this._post, this._selected, this._onTap);

  @override
  _PostGridWidgetState createState() => _PostGridWidgetState();
}

class _PostGridWidgetState extends State<PostGridWidget> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  initState() {
    super.initState();

    _controller = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this, value: 1.0);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.bounceInOut);
    if (widget._selected) {
      _controller.forward(from: 0.5);
    }
  }

  @override
  dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: InkWell(
        onTap: widget._onTap,
        child: ScaleTransition(scale: _animation, child: buildContent(context)),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    final bool isDownloaded = ChanRepository.getSync().isFileDownloaded(widget._post);
    final bool forceVideoThumbnail = isDownloaded && widget._post.hasWebm();
    return Card(
      margin: EdgeInsets.all(1.0),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          Hero(tag: widget._post.getMediaUrl(), child: ChanCachedImage(widget._post, BoxFit.cover, forceVideoThumbnail: forceVideoThumbnail)),
          if (isDownloaded) Align(alignment: Alignment.bottomRight, child: Icon(Icons.sd_storage)),
          if (widget._post.hasGif()) Align(alignment: Alignment.bottomLeft, child: Icon(Icons.gif)),
          if (widget._post.hasWebm()) Align(alignment: Alignment.bottomRight, child: Icon(Icons.play_arrow)),
        ],
      ),
    );
  }
}
