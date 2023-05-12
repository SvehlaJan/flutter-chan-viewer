import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/repositories/thumbnail_helper.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/log_utils.dart';

class ChanCachedImage extends StatelessWidget {
  final ChanPostBase post;
  final BoxFit boxFit;
  final bool forceThumbnail;
  final Duration animationDuration = const Duration(milliseconds: 400);

  const ChanCachedImage({
    required this.post,
    required this.boxFit,
    this.forceThumbnail = false,
  });

  @override
  Widget build(BuildContext context) {
    String mainUrl;
    String? thumbnailUrl;
    bool isDownloaded = getIt<ChanRepository>().isMediaDownloaded(post);

    if (forceThumbnail || post.isWebm()) {
      mainUrl = post.getThumbnailUrl()!;
    } else {
      mainUrl = post.getMediaUrl()!;
      thumbnailUrl = post.getThumbnailUrl();
    }

    if (isDownloaded && post.isImage()) {
      File imageFile = getIt<ChanStorage>().getMediaFile(post.getMediaUrl()!, post.getCacheDirective())!;
      return Image.file(
        imageFile,
        fit: boxFit,
      );
    }

    if (post.isFavorite() && post.isWebm() && isDownloaded) {
      File? thumbnailFile = ThumbnailHelper.getVideoThumbnail(post);
      if (thumbnailFile != null) {
        return Image.file(
          thumbnailFile,
          fit: boxFit,
        );
      } else {
        ThumbnailHelper.createVideoThumbnail(post).then((value) {
          LogUtils.getLogger().d("Thumbnail created: ${value?.path}");
        });
      }
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
