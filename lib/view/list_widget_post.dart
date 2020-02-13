import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/models/chan_post.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/bloc/thread_detail_bloc.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/bloc/thread_detail_event.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/view/view_cached_image.dart';
import 'package:flutter_html/flutter_html.dart';

class PostListWidget extends StatelessWidget {
  final ChanPost _post;
  final bool _selected;

  PostListWidget(this._post, this._selected);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _selected ? Constants.cardBackgroundSelected : Constants.cardBackground,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.all(2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (_post.getThumbnailUrl() != null)
            ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Constants.avatarImageSize,
                  minWidth: Constants.avatarImageSize,
                  minHeight: Constants.avatarImageSize,
                ),
                child: ChanCachedImage(_post, BoxFit.fitWidth)),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0, right: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(_post.postId.toString(), style: Theme.of(context).textTheme.caption),
                      Spacer(),
                      Text("${_post.repliesFrom.length}r", style: Theme.of(context).textTheme.caption),
                      Spacer(),
                      Text(ChanUtil.getHumanDate(_post.timestamp), style: Theme.of(context).textTheme.caption),
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                  if (_post.subtitle != null) Text(_post.subtitle, style: Theme.of(context).textTheme.subtitle),
                  Html(
                    data: ChanUtil.getReadableHtml(_post.content ?? "", false),
                    onLinkTap: ((String url) => _onLinkClicked(url, context)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _onLinkClicked(String url, BuildContext context) => BlocProvider.of<ThreadDetailBloc>(context).add(ThreadDetailEventOnLinkClicked(url));
}
