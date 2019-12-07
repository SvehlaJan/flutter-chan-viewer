import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/network_image/chan_networkimage.dart';
import 'package:flutter_chan_viewer/utils/network_image/transition_to_image.dart';

class ChanCachedImage extends StatelessWidget {
  final ChanPostBase _post;
  final BoxFit _boxFit;
  final bool forceThumbnail;
  final bool showProgress;
  final bool usePermanentCache;

  ChanCachedImage(this._post, this._boxFit, {this.forceThumbnail = false, this.showProgress = false, this.usePermanentCache = false});

  @override
  Widget build(BuildContext context) {
    final bool thumbnailOnly = forceThumbnail || !_post.hasImage();
    final String _url = thumbnailOnly ? _post.getThumbnailUrl() : _post.getImageUrl();
    final String _thumbnailUrl = thumbnailOnly ? null : _post.getThumbnailUrl();
    final bool _usePermanentCache = usePermanentCache && !thumbnailOnly; // we don't want to permanently cache thumbnails

    return ChanTransitionToImage(
      image: ChanNetworkImage(_url, cacheDirective: _usePermanentCache ? _post.getCacheDirective() : null),
      loadFailedCallback: () {
        print('Failed to load image: $_url');
      },
      placeholder: Icon(Icons.sync_problem, size: Constants.errorPlaceholderSize),
      loadingWidget: _buildLoadingWidget(_thumbnailUrl),
      loadingWidgetBuilder: showProgress
          ? (BuildContext context, double progress, Uint8List imageData) {
              return Stack(
                fit: StackFit.passthrough,
                children: <Widget>[
                  _buildLoadingWidget(_thumbnailUrl),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: 2.0,
                      child: LinearProgressIndicator(
                        value: progress == 0.0 ? null : progress,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  )
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
        ? ChanTransitionToImage(image: ChanNetworkImage(url, cacheDirective: null), fit: _boxFit, loadingWidget: Center(child: Constants.progressIndicator))
        : Center(child: Constants.progressIndicator);
  }
}
