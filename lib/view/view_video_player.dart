import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/view/view_cached_image.dart';

class ChanVideoPlayer extends StatefulWidget {
  final PostItem post;

  const ChanVideoPlayer({
    required this.post,
  });

  @override
  _ChanVideoPlayerState createState() => _ChanVideoPlayerState();
}

class _ChanVideoPlayerState extends State<ChanVideoPlayer> {
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    super.initState();

    var betterPlayerConfiguration = BetterPlayerConfiguration(
        autoPlay: true,
        looping: true,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          controlBarHeight: 120,
          showControlsOnInitialize: false,
          backgroundColor: Colors.transparent,
          forwardSkipTimeInMilliseconds: 5000,
          backwardSkipTimeInMilliseconds: 5000,
          enableMute: false,
          enableSubtitles: false,
          enableQualities: false,
          enableAudioTracks: false,
        ),
        aspectRatio: 0.1,
        placeholder: _buildLoadingView(context),
        showPlaceholderUntilPlay: true,
        fullScreenByDefault: false,
        fit: BoxFit.contain);

    if (getIt<ChanRepository>().isMediaDownloaded(widget.post)) {
      File file = getIt<ChanStorage>().getMediaFile(widget.post.getMediaUrl()!, widget.post.getCacheDirective())!;
      BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.file,
        file.absolute.path,
      );
      _betterPlayerController = BetterPlayerController(
        betterPlayerConfiguration,
        betterPlayerDataSource: betterPlayerDataSource,
      );
    } else {
      BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.post.getMediaUrl()!,
        cacheConfiguration: BetterPlayerCacheConfiguration(
          useCache: true,
          maxCacheSize: 256 * 1024 * 1024,
          maxCacheFileSize: 10 * 1024 * 1024,
        ),
      );
      _betterPlayerController =
          BetterPlayerController(betterPlayerConfiguration, betterPlayerDataSource: betterPlayerDataSource);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildVideoView(context);
  }

  Widget _buildVideoView(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(),
      child: BetterPlayer(
        controller: _betterPlayerController,
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
    // _videoController.dispose();
    // _bottomChewieController.dispose();

    super.dispose();
  }
}
