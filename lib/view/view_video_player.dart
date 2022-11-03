import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/view/view_cached_image.dart';

import '../utils/preferences.dart';

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
          enableMute: true,
          enableSubtitles: false,
          enableQualities: false,
          enableAudioTracks: false,
        ),
        eventListener: (betterPlayerEvent) {
          switch (betterPlayerEvent.betterPlayerEventType) {
            case BetterPlayerEventType.initialized:
              double volume = getIt<Preferences>().getDouble(Preferences.KEY_PLAYER_VOLUME, def: 0.0);
              _betterPlayerController.setVolume(volume);
              break;
            case BetterPlayerEventType.setVolume:
              double? volume = betterPlayerEvent.parameters?["volume"];
              getIt<Preferences>().setDouble(Preferences.KEY_PLAYER_VOLUME, volume ?? 0.0);
              break;
            default:
              break;
          }
        },
        aspectRatio: 0.001,
        placeholder: _buildLoadingView(context),
        showPlaceholderUntilPlay: true,
        fullScreenByDefault: false,
        autoDispose: true,
        fit: BoxFit.contain);
    var bufferingConfiguration = BetterPlayerBufferingConfiguration(
        minBufferMs: 2000, maxBufferMs: 10000, bufferForPlaybackMs: 1000, bufferForPlaybackAfterRebufferMs: 2000);

    if (getIt<ChanRepository>().isMediaDownloaded(widget.post)) {
      File file = getIt<ChanStorage>().getMediaFile(widget.post.getMediaUrl()!, widget.post.getCacheDirective())!;
      BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.file,
        file.absolute.path,
        bufferingConfiguration: bufferingConfiguration,
      );
      _betterPlayerController = BetterPlayerController(
        betterPlayerConfiguration,
        betterPlayerDataSource: betterPlayerDataSource,
      );
    } else {
      BetterPlayerCacheConfiguration cacheConfiguration = BetterPlayerCacheConfiguration(
        useCache: true,
        maxCacheSize: 256 * 1024 * 1024, // 256 MB
        maxCacheFileSize: 16 * 1024 * 1024, // 16 MB
      );
      BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.post.getMediaUrl()!,
        cacheConfiguration: cacheConfiguration,
        bufferingConfiguration: bufferingConfiguration,
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
    _betterPlayerController.dispose(forceDispose: true);
    super.dispose();
  }
}
