import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/view/view_cached_image.dart';
import 'package:video_player/video_player.dart';

class ChanVideoPlayer extends StatefulWidget {
  final ChanPost _post;

  ChanVideoPlayer(this._post);

  @override
  _ChanVideoPlayerState createState() => _ChanVideoPlayerState();
}

class _ChanVideoPlayerState extends State<ChanVideoPlayer> {
  VideoPlayerController _videoController;
  ChewieController _chewieController;

  @override
  void initState() {
    super.initState();

    ChanStorage cache = ChanStorage.getSync();
    if (cache.mediaFileExists(widget._post.getMediaUrl(), widget._post.getCacheDirective())) {
      File file = cache.getMediaFile(widget._post.getMediaUrl(), widget._post.getCacheDirective());
      _videoController = VideoPlayerController.file(file);
    } else {
      _videoController = VideoPlayerController.network(widget._post.getMediaUrl());
    }

    _videoController.initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: true,
        looping: true,
        showControlsOnInitialize: false,
        aspectRatio: _videoController.value.aspectRatio,
      );
      setState(() {
        _chewieController.play();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (() {
        setState(() {
          _videoController.value.isPlaying ? _videoController.pause() : _videoController.play();
        });
      }),
      child: _videoController.value.initialized ? Center(child: Chewie(controller: _chewieController)) : ChanCachedImage(widget._post, BoxFit.contain),
    );
  }

  @override
  void dispose() {
    if (_videoController != null) _videoController.dispose();
    if (_chewieController != null) _chewieController.dispose();

    super.dispose();
  }
}
