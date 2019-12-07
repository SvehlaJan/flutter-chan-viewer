import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_viewer_bloc/chan_viewer_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_viewer_bloc/chan_viewer_event.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/bloc/thread_detail_event.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/network_image/chan_networkimage.dart';
import 'package:flutter_chan_viewer/view/view_cached_image.dart';
import 'package:flutter_chan_viewer/view/view_custom_carousel.dart';
import 'package:flutter_chan_viewer/view/view_video_player.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../thread_detail/bloc/thread_detail_bloc.dart';
import '../thread_detail/bloc/thread_detail_state.dart';

class GalleryPage extends BasePage {
  static const String ARG_BOARD_ID = "ChanGallery.ARG_BOARD_ID";
  static const String ARG_THREAD_ID = "ChanGallery.ARG_THREAD_ID";
  static const String ARG_POST_ID = "ChanGallery.ARG_POST_ID";
  static const bool enableInfiniteScroll = true;

  static Map<String, dynamic> getArguments(final String boardId, final int threadId, final int postId) =>
      {GalleryPage.ARG_BOARD_ID: boardId, GalleryPage.ARG_THREAD_ID: threadId, GalleryPage.ARG_POST_ID: postId};

  GalleryPage();

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends BasePageState<GalleryPage> with TickerProviderStateMixin {
  static const int DOUBLE_TAP_TIMEOUT = 300;
  static const double SCALE_MIN = 1.0;
  static const double SCALE_MAX = 10.0;
  static const double IS_SCALED_THRESHOLD = 1.2;
  static const int SCALE_ANIMATION_DURATION = 200;

  ThreadDetailBloc _threadDetailBloc;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ChanViewerBloc>(context).add(ChanViewerEventShowBottomBar(false));
    _threadDetailBloc = BlocProvider.of<ThreadDetailBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThreadDetailBloc, ThreadDetailState>(bloc: _threadDetailBloc, builder: (context, state) => buildPage(buildBody(context, state)));
  }

  Widget buildBody(BuildContext context, ThreadDetailState state) {
    if (state is ThreadDetailStateLoading) {
      return Constants.centeredProgressIndicator;
    }
    if (state is ThreadDetailStateContent) {
      if (state.model.posts.isEmpty) {
        return Constants.noDataPlaceholder;
      }

      return SafeArea(
        child: Stack(
          children: <Widget>[
            PhotoViewGallery.builder(
              itemCount: state.model.mediaPosts.length,
              builder: (context, index) {
                return buildItem(context, state.model.mediaPosts[index]);
              },
              scrollPhysics: BouncingScrollPhysics(),
              // Set the background color to the "classic white"
              backgroundDecoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
              loadingChild: Center(child: Constants.progressIndicator),
              pageController: PageController(initialPage: state.selectedMediaIndex),
              onPageChanged: ((pageIndex) {

                if (pageIndex != state.selectedMediaIndex) {
                  _threadDetailBloc.add(ThreadDetailEventOnPostSelected(pageIndex, null));
                }
//                setState(() {
//                  _threadDetailBloc.selectedMediaIndex = pageIndex;
//                });
              }),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "${state.selectedMediaIndex + 1}/${state.model.mediaPosts.length}",
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Constants.errorPlaceholder;
    }
  }

  PhotoViewGalleryPageOptions buildItem(BuildContext context, ChanPost post) {
    if (post.hasImage()) {
      return PhotoViewGalleryPageOptions(
        imageProvider: ChanNetworkImage(post.getImageUrl(), cacheDirective: null),
        heroAttributes: PhotoViewHeroAttributes(tag: post.getMediaUrl()),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
      );
    } else {
      return PhotoViewGalleryPageOptions.customChild(
        child: ChanVideoPlayer(post),
        childSize: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
        heroAttributes: PhotoViewHeroAttributes(tag: post.getMediaUrl()),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
      );
    }
  }

//  ChanCachedImage(post, BoxFit.contain, showProgress: true)
}
