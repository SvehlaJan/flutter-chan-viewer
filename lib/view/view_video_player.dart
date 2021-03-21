import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/view/view_cached_image.dart';
import 'package:video_player/video_player.dart';

class ChanVideoPlayer extends StatefulWidget {
  final PostItem post;

  const ChanVideoPlayer({
    required this.post,
  });

  @override
  _ChanVideoPlayerState createState() => _ChanVideoPlayerState();
}

class _ChanVideoPlayerState extends State<ChanVideoPlayer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();

    if (getIt<ChanStorage>().mediaFileExists(widget.post.getMediaUrl()!, widget.post.getCacheDirective())) {
      File file = getIt<ChanStorage>().getMediaFile(widget.post.getMediaUrl()!, widget.post.getCacheDirective())!;
      _videoController = VideoPlayerController.file(file);
    } else {
      _videoController = VideoPlayerController.network(widget.post.getMediaUrl()!);
    }

    _videoController!.initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: true,
        showControlsOnInitialize: false,
        aspectRatio: _videoController!.value.aspectRatio,
      );
      setState(() {
        _chewieController!.play();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _videoController!.value.isInitialized ? _buildVideoView(context) : _buildLoadingView(context);
  }

  Widget _buildVideoView(BuildContext context) {
    return GestureDetector(
        onTap: (() {
          setState(() {
            _videoController!.value.isPlaying ? _videoController!.pause() : _videoController!.play();
          });
        }),
        child: Chewie(controller: _chewieController!));
  }

  Widget _buildLoadingView(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[ChanCachedImage(post: widget.post, boxFit: BoxFit.contain), Constants.centeredProgressIndicator],
    );
  }

  @override
  void dispose() {
    if (_videoController != null) _videoController!.dispose();
    if (_chewieController != null) _chewieController!.dispose();

    super.dispose();
  }
}
