import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chan_viewer/models/api/posts_model.dart';
import 'package:flutter_chan_viewer/view/view_cached_image.dart';

class PostGridWidget extends StatelessWidget {
  final ChanPost _post;
  final void Function() _onItemClick;

  PostGridWidget(this._post, this._onItemClick);

  @override
  Widget build(BuildContext context) {
    print("Building PostListWidget { imageUrl: ${_post.getImageUrl()} }");
    return GridTile(
      child: GestureDetector(
        onTap: () {
          _onItemClick();
        },
        child: _post.hasImage() ? ChanCachedImage(_post.getImageUrl(), _post.getThumbnailUrl()) : ChanCachedImage(_post.getThumbnailUrl()),
      ),
    );
  }
}
