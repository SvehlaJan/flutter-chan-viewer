import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/view/network_image/chan_networkimage.dart';
import 'package:flutter_chan_viewer/view/network_image/transition_to_image.dart';

class ChanCachedImage extends StatelessWidget {
  final ChanPostBase post;
  final BoxFit boxFit;
  final bool forceThumbnail;
  final bool isDownloaded;
  final bool showProgress;

  const ChanCachedImage({
    @required this.post,
    @required this.boxFit,
    this.forceThumbnail = false,
    this.isDownloaded = false,
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    String mainUrl;
    String fallbackUrl;
    String thumbnailUrl;
    CacheDirective cacheDirective = (post.isFavorite() || !forceThumbnail) ? post.getCacheDirective() : null;

    if (forceThumbnail) {
      if (post.isFavorite()) {
        mainUrl = post.getMediaUrl();
        fallbackUrl = post.getThumbnailUrl();
      } else {
        mainUrl = post.getThumbnailUrl();
      }
    } else {
      if (post.hasWebm()) {
        if (post.isFavorite()) {
          mainUrl = post.getMediaUrl();
          fallbackUrl = post.getThumbnailUrl();
        } else {
          mainUrl = post.getThumbnailUrl();
        }
      } else {
        mainUrl = post.getMediaUrl();
      }
      thumbnailUrl = post.getThumbnailUrl();
    }

    return ChanTransitionToImage(
      image: ChanNetworkImage(mainUrl, fallbackUrl, cacheDirective),
      loadFailedCallback: () {
        print('Failed to load image: $mainUrl');
      },
      placeholder: Icon(Icons.sync_problem, size: Constants.errorPlaceholderSize),
      loadingWidgetBuilder: showProgress
          ? (BuildContext context, double progress, Uint8List imageData) {
              return Stack(
                fit: StackFit.passthrough,
                children: <Widget>[
                  _buildLoadingWidget(thumbnailUrl),
                  if (progress > 0) Align(alignment: Alignment.bottomCenter, child: SizedBox(height: 2.0, child: LinearProgressIndicator(value: progress))),
                ],
              );
            }
          : null,
      fit: boxFit,
      enableRefresh: true,
      printError: true,
    );
  }

  Widget _buildLoadingWidget(String url) {
    return (url != null)
        ? ChanTransitionToImage(image: ChanNetworkImage(url, null, null), fit: boxFit, loadingWidget: Center(child: Constants.progressIndicator))
        : Center(child: Constants.progressIndicator);
  }
}
