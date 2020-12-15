import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';

class ChanCachedImage extends StatelessWidget {
  final ChanPostBase post;
  final BoxFit boxFit;
  final bool forceThumbnail;
  final Duration animationDuration = const Duration(milliseconds: 400);

  const ChanCachedImage({
    @required this.post,
    @required this.boxFit,
    this.forceThumbnail = false,
  });

  @override
  Widget build(BuildContext context) {
    String mainUrl;
    String thumbnailUrl;
    bool isDownloaded = getIt<ChanRepository>().isMediaDownloaded(post);

    if (forceThumbnail || post.hasWebm()) {
      mainUrl = post.getThumbnailUrl();
    } else {
      mainUrl = post.getMediaUrl();
      thumbnailUrl = post.getThumbnailUrl();
    }

    if (isDownloaded && post.hasImage()) {
      File imageFile = getIt<ChanStorage>().getMediaFile(post.getMediaUrl(), post.getCacheDirective());
      return Image.file(
        imageFile,
        fit: boxFit,
      );
    } else if (post.isFavorite()) {
      getIt<CacheManager>().downloadFile(post.getMediaUrl()).then((fileInfo) {
        return fileInfo.file.readAsBytes().then((imageData) {
          return getIt<ChanStorage>().writeMediaFile(post.getMediaUrl(), post.getCacheDirective(), imageData);
        });
      });
    }

    return CachedNetworkImage(
      cacheManager: getIt<CacheManager>(),
      imageUrl: mainUrl,
      placeholder: (context, url) => _buildPlaceholderWidget(thumbnailUrl),
      errorWidget: (context, url, error) => Icon(Icons.error),
      fadeInDuration: animationDuration,
      fadeOutDuration: animationDuration,
      placeholderFadeInDuration: animationDuration,
      fit: boxFit,
    );
  }

  Widget _buildPlaceholderWidget(String url) {
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
