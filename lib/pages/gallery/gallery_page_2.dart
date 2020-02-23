import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/models/chan_post.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/bloc/thread_detail_event.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/network_image/chan_networkimage.dart';
import 'package:flutter_chan_viewer/view/list_widget_post.dart';
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
//    BlocProvider.of<ChanViewerBloc>(context).add(ChanViewerEventShowBottomBar(false));
    _threadDetailBloc = BlocProvider.of<ThreadDetailBloc>(context);
    _threadDetailBloc.add(ThreadDetailEventShowContent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ThreadDetailBloc, ThreadDetailState>(
      listener: (context, state) => resolveAction(context, state),
      builder: (context, state) => buildPage(context, buildBody(context, state)),
    );

    return BlocBuilder<ThreadDetailBloc, ThreadDetailState>(bloc: _threadDetailBloc, builder: (context, state) => buildPage(context, buildBody(context, state)));
  }

  void resolveAction(BuildContext context, ThreadDetailState state) {
    if (state is ThreadDetailStateCloseGallery) {
      Navigator.pop(context, false);
    }
  }

  Widget buildBody(BuildContext context, ThreadDetailState state) {
    if (state is ThreadDetailStateLoading) {
      return Constants.centeredProgressIndicator;
    }
    if (state is ThreadDetailStateShowList) {
      if (state.model.posts.isEmpty) {
        return Constants.noDataPlaceholder;
      }

      ChanPost post = state.model.mediaPosts[state.selectedMediaIndex];
      return SafeArea(
        child: Stack(
          children: <Widget>[
            PhotoViewGallery.builder(
              itemCount: state.model.mediaPosts.length,
              builder: (context, index) {
                return buildItem(context, state.model.mediaPosts[index]);
              },
              scrollPhysics: BouncingScrollPhysics(),
              backgroundDecoration: BoxDecoration(color: Colors.transparent),
              loadingChild: Center(child: Constants.progressIndicator),
              pageController: PageController(initialPage: state.selectedMediaIndex),
              onPageChanged: ((pageIndex) {
                if (pageIndex != state.selectedMediaIndex) {
                  _threadDetailBloc.add(ThreadDetailEventOnPostSelected(pageIndex, null));
                }
                DraggableScrollableActuator.reset(context);
              }),
            ),
            if (post.hasReplies) _buildBottomView(post),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text("${state.selectedMediaIndex + 1}/${state.model.mediaPosts.length}", style: Theme.of(context).textTheme.caption),
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
        imageProvider: ChanNetworkImage(post.getImageUrl(), post.getCacheDirective()),
        heroAttributes: PhotoViewHeroAttributes(tag: post.getMediaUrl()),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
        scaleStateCycle: customScaleStateCycle,
      );
    } else {
      return PhotoViewGalleryPageOptions.customChild(
        child: ChanVideoPlayer(post),
        childSize: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
        heroAttributes: PhotoViewHeroAttributes(tag: post.getMediaUrl()),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
        scaleStateCycle: customScaleStateCycle,
      );
    }
  }

  PhotoViewScaleState customScaleStateCycle(PhotoViewScaleState actual) {
    switch (actual) {
      case PhotoViewScaleState.initial:
        return PhotoViewScaleState.covering;
      case PhotoViewScaleState.covering:
        return PhotoViewScaleState.originalSize;
      case PhotoViewScaleState.originalSize:
        return PhotoViewScaleState.initial;
      case PhotoViewScaleState.zoomedIn:
      case PhotoViewScaleState.zoomedOut:
        return PhotoViewScaleState.initial;
      default:
        return PhotoViewScaleState.initial;
    }
  }

  Widget _buildBottomView(ChanPost post) {
    return DraggableScrollableSheet(
      expand: true,
      initialChildSize: 0.05,
      minChildSize: 0.05,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
            color: Colors.white60,
            child: ListView.builder(
              padding: EdgeInsets.all(4),
              shrinkWrap: true,
              controller: scrollController,
              itemCount: post.repliesFrom.length,
              itemBuilder: (context, index) {
                return PostListWidget(post.repliesFrom[index], false, () => _onReplyPostClicked(post.repliesFrom[index], context), (url) => _onLinkClicked(url, context));
              },
            ),
          ),
        );
      },
    );
  }

  void _onReplyPostClicked(ChanPost post, BuildContext context) => _threadDetailBloc.add(ThreadDetailEventOnReplyClicked(post.postId));

  void _onLinkClicked(String url, BuildContext context) => _threadDetailBloc.add(ThreadDetailEventOnReplyClicked(ChanUtil.getPostIdFromUrl(url)));
}
