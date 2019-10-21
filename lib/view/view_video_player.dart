import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan_viewer/models/api/posts_model.dart';
import 'package:flutter_chan_viewer/view/view_cached_image.dart';
import 'package:video_player/video_player.dart';

class ChanVideoPlayer extends StatefulWidget {
  final ChanPost _post;
  final void Function() _onItemClick;

  ChanVideoPlayer(this._post, this._onItemClick);

  @override
  _ChanVideoPlayerState createState() => _ChanVideoPlayerState();
}

class _ChanVideoPlayerState extends State<ChanVideoPlayer> {
  VideoPlayerController _videoController;
  ChewieController _chewieController;

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.network(widget._post.getImageUrl())
      ..initialize().then((_) {
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
      child: _videoController.value.initialized
          ? Center(
              child: Chewie(
                controller: _chewieController,
              ),
            )
          : ChanCachedImage(widget._post.getThumbnailUrl()),
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController.dispose();

    super.dispose();
  }
}
