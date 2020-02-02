import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/view/view_cached_image.dart';

class PostGridWidget extends StatelessWidget {
  final ChanPost _post;
  final bool _selected;

  PostGridWidget(this._post, this._selected);

  @override
  Widget build(BuildContext context) {
    final bool isDownloaded = ChanRepository.getSync().isFileDownloaded(_post);
    return GridTile(
      child: Container(
        color: _selected ? Constants.cardBackgroundSelected : Constants.cardBackground,
        padding: const EdgeInsets.all(2.0),
        child: Card(
          margin: EdgeInsets.all(0.0),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.passthrough,
            children: <Widget>[
              ChanCachedImage(_post, BoxFit.cover),
              if (isDownloaded) Align(alignment: Alignment.bottomRight, child: Icon(Icons.sd_storage)),
              if (_post.hasVideo()) Align(alignment: Alignment.bottomLeft, child: Icon(Icons.play_arrow)),
            ],
          ),
        ),
      ),
    );
  }
}
