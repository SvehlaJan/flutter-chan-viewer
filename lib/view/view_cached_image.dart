import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';

class ChanCachedImage extends StatelessWidget {
  final String _url;
  final String _thumbnailUrl;

  ChanCachedImage(this._url, [this._thumbnailUrl]);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        if (_thumbnailUrl != null)
          TransitionToImage(
            image: AdvancedNetworkImage(
              _thumbnailUrl,
              retryLimit: 3,
              useDiskCache: true,
              cacheRule: CacheRule(maxAge: const Duration(days: 7)),
            ),
            loadingWidget: Container(),
            fit: BoxFit.fill,
          ),
        TransitionToImage(
          image: AdvancedNetworkImage(
            _url,
            retryLimit: 3,
            useDiskCache: true,
            cacheRule: CacheRule(maxAge: const Duration(days: 7)),
          ),
          loadFailedCallback: () {
            print('Failed to load image: $_url');
          },
          loadingWidgetBuilder: (
            BuildContext context,
            double progress,
            Uint8List imageData,
          ) {
            return Container(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 2.0,
                child: LinearProgressIndicator(
                  value: progress == 0.0 ? null : progress,
                  backgroundColor: Colors.transparent,
                ),
              ),
            );
          },
          fit: BoxFit.fitWidth,
          enableRefresh: true,
        ),
      ],
    );
  }
}
