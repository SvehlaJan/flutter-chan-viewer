import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/network_image/chan_networkimage.dart';
import 'package:flutter_chan_viewer/utils/network_image/transition_to_image.dart';

class ChanCachedImage extends StatelessWidget {
  final ChanPostBase _post;
  final BoxFit _boxFit;
  final bool forceThumbnail;
  final bool showProgress;
  final bool usePermanentCache;

  ChanCachedImage(this._post, this._boxFit, {this.forceThumbnail = false, this.showProgress = true, this.usePermanentCache = false});

  @override
  Widget build(BuildContext context) {
    final bool thumbnailOnly = forceThumbnail || !_post.hasImage();
    final String mainUrl = thumbnailOnly ? _post.getThumbnailUrl() : _post.getMediaUrl();
    final String thumbnailUrl = thumbnailOnly ? null : _post.getThumbnailUrl();
    final CacheDirective cacheDirective = thumbnailOnly ? null : _post.getCacheDirective();

    return ChanTransitionToImage(
      image: ChanNetworkImage(mainUrl, cacheDirective),
      loadFailedCallback: () {
        ChanLogger.e('Failed to load image: $mainUrl');
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
      fit: _boxFit,
      enableRefresh: true,
      printError: true,
    );
  }

  Widget _buildLoadingWidget(String url) {
    return (url != null)
        ? ChanTransitionToImage(image: ChanNetworkImage(url, null), fit: _boxFit, loadingWidget: Center(child: Constants.progressIndicator))
        : Center(child: Constants.progressIndicator);
  }
}
