import 'dart:io';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/view/view_cached_image.dart';

class ChanVideoPlayerVlc extends StatefulWidget {
  final PostItem post;

  const ChanVideoPlayerVlc({
    required this.post,
  });

  @override
  _ChanVideoPlayerVlcState createState() => _ChanVideoPlayerVlcState();
}

class _ChanVideoPlayerVlcState extends State<ChanVideoPlayerVlc> {
  late Player _player;

  @override
  void initState() {
    super.initState();

    List<Media> media = [];
    if (getIt<ChanRepository>().isMediaDownloaded(widget.post)) {
      File file = getIt<ChanStorage>().getMediaFile(widget.post.getMediaUrl()!, widget.post.getCacheDirective())!;
      media.add(Media.file(file));
    } else {
      media.add(Media.network(widget.post.getMediaUrl()!));
    }
    _player = Player(id: widget.post.postId);
    _player.open(Playlist(medias: media));
  }

  @override
  Widget build(BuildContext context) {
    return _buildVideoView(context);
  }

  Widget _buildVideoView(BuildContext context) {
    return Material(
      child: Container(
        constraints: BoxConstraints.expand(),
        child: Video(
          player: _player,
          showControls: true,
        ),
      ),
    );
  }

  Widget _buildLoadingView(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        ChanCachedImage(post: widget.post, boxFit: BoxFit.contain),
        Constants.centeredProgressIndicator
      ],
    );
  }

  @override
  void dispose() {
    _player.stop();
    _player.dispose();

    super.dispose();
  }
}
