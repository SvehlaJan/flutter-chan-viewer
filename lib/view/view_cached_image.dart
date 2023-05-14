import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/media_helper.dart';

class ChanCachedImage extends StatelessWidget {
  final ImageSource imageSource;
  final BoxFit boxFit;
  final Duration animationDuration = const Duration(milliseconds: 400);

  const ChanCachedImage({
    required this.imageSource,
    required this.boxFit,
  });

  @override
  Widget build(BuildContext context) {
    switch (imageSource) {
      case NetworkImageSource _:
        final source = imageSource as NetworkImageSource;
        return CachedNetworkImage(
          cacheManager: getIt<CacheManager>(),
          imageUrl: source.mainUrl,
          placeholder: (context, url) => _buildPlaceholderWidget(source.thumbnailUrl),
          errorWidget: (context, url, error) => Icon(Icons.error),
          fadeInDuration: animationDuration,
          fadeOutDuration: animationDuration,
          placeholderFadeInDuration: animationDuration,
          fit: boxFit,
        );
      case FileImageSource _:
        final source = imageSource as FileImageSource;
        return Image.file(
          File(source.filePath),
          fit: boxFit,
        );
    }
  }

  Widget _buildPlaceholderWidget(String? url) {
    return (url != null)
        ? CachedNetworkImage(
            cacheManager: getIt<CacheManager>(),
            imageUrl: url,
            fit: boxFit,
            placeholder: (context, url) => Constants.centeredProgressIndicator,
            fadeInDuration: Duration.zero,
            fadeOutDuration: Duration.zero,
            placeholderFadeInDuration: Duration.zero,
          )
        : Constants.centeredProgressIndicator;
  }
}
