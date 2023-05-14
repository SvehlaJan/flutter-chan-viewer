import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/media_helper.dart';
import 'package:flutter_chan_viewer/view/view_cached_image.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class ChanVideoPlayerNew extends StatefulWidget {
  final VideoSource videoSource;

  const ChanVideoPlayerNew({
    required this.videoSource,
  });

  @override
  _ChanVideoPlayerStateNew createState() => _ChanVideoPlayerStateNew();
}

class _ChanVideoPlayerStateNew extends State<ChanVideoPlayerNew> {
  late VlcPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();

    switch (widget.videoSource) {
      case NetworkVideoSource _:
        NetworkVideoSource source = widget.videoSource as NetworkVideoSource;
        _videoPlayerController = VlcPlayerController.network(
          source.url,
          hwAcc: HwAcc.full,
          autoPlay: true,
          options: VlcPlayerOptions(),
        );
        break;
      case FileVideoSource _:
        FileVideoSource source = widget.videoSource as FileVideoSource;
        _videoPlayerController = VlcPlayerController.file(
          new File(source.filePath),
          hwAcc: HwAcc.full,
          autoPlay: true,
          options: VlcPlayerOptions(),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildVideoView(context);
  }

  Widget _buildVideoView(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: VlcPlayer(
        controller: _videoPlayerController,
        aspectRatio: 16 / 9,
        placeholder: _buildLoadingView(context, widget.videoSource.placeholderSource),
      ),
    );
  }

  Widget _buildLoadingView(BuildContext context, ImageSource imageSource) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        ChanCachedImage(imageSource: imageSource, boxFit: BoxFit.contain),
        Constants.centeredProgressIndicator
      ],
    );
  }

  @override
  void dispose() async {
    await _videoPlayerController.stopRendererScanning();
    super.dispose();
  }
}
