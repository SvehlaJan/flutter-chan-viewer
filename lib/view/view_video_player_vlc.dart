import 'dart:io';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/media_helper.dart';
import 'package:flutter_chan_viewer/view/view_cached_image.dart';

class ChanVideoPlayerVlc extends StatefulWidget {
  final VideoSource videoSource;

  const ChanVideoPlayerVlc({
    required this.videoSource,
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
    switch (widget.videoSource) {
      case NetworkVideoSource _:
        final source = widget.videoSource as NetworkVideoSource;
        media.add(Media.network(source.url));
        break;
      case FileVideoSource _:
        final source = widget.videoSource as FileVideoSource;
        media.add(Media.file(File(source.filePath)));
        break;
    }
    _player = Player(id: widget.videoSource.postId);
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

  Widget _buildLoadingView(BuildContext context, ImageSource placeholderSource) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        ChanCachedImage(imageSource: placeholderSource, boxFit: BoxFit.contain),
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
