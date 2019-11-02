import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/network_image/chan_networkimage.dart';
import 'package:flutter_chan_viewer/utils/network_image/transition_to_image.dart';

class ChanCachedImage extends StatelessWidget {
  final String _url;
  final String _thumbnailUrl;
  final bool _showProgress;
  final BoxFit _boxFit = BoxFit.fitWidth;

  ChanCachedImage(this._url, [this._thumbnailUrl, this._showProgress = false]);

  @override
  Widget build(BuildContext context) {
    return ChanTransitionToImage(
      image: ChanNetworkImage(_url),
      loadFailedCallback: () {
        print('Failed to load image: $_url');
      },
      loadingWidget: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: <Widget>[
          Center(child: Constants.progressIndicator),
          if (_thumbnailUrl != null) Image(image: ChanNetworkImage(_thumbnailUrl), fit: _boxFit),
        ],
      ),
      loadingWidgetBuilder: _showProgress
          ? (BuildContext context, double progress, Uint8List imageData) {
              print("progress: $progress");
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
            }
          : null,
      fit: _boxFit,
      enableRefresh: true,
    );
  }
}
