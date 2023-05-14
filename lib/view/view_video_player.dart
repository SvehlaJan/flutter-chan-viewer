import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/media_helper.dart';
import 'package:flutter_chan_viewer/view/view_cached_image.dart';

import '../utils/preferences.dart';

class ChanVideoPlayer extends StatefulWidget {
  final VideoSource videoSource;

  const ChanVideoPlayer({
    required this.videoSource,
  });

  @override
  _ChanVideoPlayerState createState() => _ChanVideoPlayerState();
}

class _ChanVideoPlayerState extends State<ChanVideoPlayer> {
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    super.initState();

    late BetterPlayerDataSource betterPlayerDataSource;
    BetterPlayerConfiguration betterPlayerConfiguration = BetterPlayerConfiguration(
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
        placeholder: _buildLoadingView(context, widget.videoSource.placeholderSource),
        showPlaceholderUntilPlay: true,
        fullScreenByDefault: false,
        autoDispose: true,
        fit: BoxFit.contain);
    BetterPlayerBufferingConfiguration bufferingConfiguration = BetterPlayerBufferingConfiguration(
        minBufferMs: 2000, maxBufferMs: 10000, bufferForPlaybackMs: 1000, bufferForPlaybackAfterRebufferMs: 2000);

    switch (widget.videoSource) {
      case NetworkVideoSource _:
        final source = widget.videoSource as NetworkVideoSource;
        BetterPlayerCacheConfiguration cacheConfiguration = BetterPlayerCacheConfiguration(
          useCache: true,
          maxCacheSize: 256 * 1024 * 1024, // 256 MB
          maxCacheFileSize: 16 * 1024 * 1024, // 16 MB
        );
        betterPlayerDataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          source.url,
          cacheConfiguration: cacheConfiguration,
          bufferingConfiguration: bufferingConfiguration,
        );
        break;
      case FileVideoSource _:
        final source = widget.videoSource as FileVideoSource;
        betterPlayerDataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.file,
          source.filePath,
          bufferingConfiguration: bufferingConfiguration,
        );
    }
    _betterPlayerController =
        BetterPlayerController(betterPlayerConfiguration, betterPlayerDataSource: betterPlayerDataSource);
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
    _betterPlayerController.dispose(forceDispose: true);
    super.dispose();
  }
}
