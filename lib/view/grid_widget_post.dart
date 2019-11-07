import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chan_viewer/models/posts_model.dart';
import 'package:flutter_chan_viewer/view/view_cached_image.dart';

class PostGridWidget extends StatelessWidget {
  final ChanPost _post;

  PostGridWidget(this._post);

  @override
  Widget build(BuildContext context) {
    print("Building PostListWidget { imageUrl: ${_post.getMediaUrl()} }");
    return GridTile(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: ChanCachedImage(_post, boxFit: BoxFit.cover),
      ),
    );
  }
}
