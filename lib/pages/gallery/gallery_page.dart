import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/bloc/thread_detail_event.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/view/list_widget_post.dart';
import 'package:flutter_chan_viewer/view/network_image/chan_networkimage.dart';
import 'package:flutter_chan_viewer/view/view_cached_image.dart';
import 'package:flutter_chan_viewer/view/view_video_player.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../thread_detail/bloc/thread_detail_bloc.dart';
import '../thread_detail/bloc/thread_detail_state.dart';

class GalleryPage extends StatefulWidget {
  final bool showAsReply;
  final int selectedPostId;

  const GalleryPage({
    @required this.showAsReply,
    this.selectedPostId = -1,
  });

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
    _threadDetailBloc = BlocProvider.of<ThreadDetailBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThreadDetailBloc, ChanState>(
        bloc: _threadDetailBloc,
        builder: (context, state) => buildScaffold(
              context,
              widget.showAsReply ? _buildSinglePostBody(context, state, widget.selectedPostId) : _buildCarouselBody(context, state),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
            ));
  }

  Widget _buildSinglePostBody(BuildContext context, ChanState state, int postId) {
    if (state is ChanStateLoading) {
      return Constants.centeredProgressIndicator;
    } else if (state is ThreadDetailStateContent) {
      PostItem post = state.model.findPostById(postId);

      return SafeArea(
        child: Stack(
          children: <Widget>[
            _buildSinglePostItem(context, post),
            _buildBottomView(post),
          ],
        ),
      );
    } else {
      return BasePageState.buildErrorScreen(context, (state as ChanStateError)?.message);
    }
  }

  Widget _buildSinglePostItem(BuildContext context, PostItem post) {
    if (post.hasImage() || post.hasGif()) {
      return Center(child: ChanCachedImage(post: post, boxFit: BoxFit.fitWidth));
    } else if (post.hasWebm()) {
      return ChanVideoPlayer(post: post);
    } else {
      return Container();
    }
  }

  Widget _buildCarouselBody(BuildContext context, ChanState state) {
    if (state is ChanStateLoading) {
      return Constants.centeredProgressIndicator;
    } else if (state is ThreadDetailStateContent) {
      int mediaIndex = state.selectedMediaIndex;
      if (mediaIndex < 0) {
        // for case when non-media post is selected
        return Constants.noDataPlaceholder;
      }

      PostItem post = state.model.mediaPosts[mediaIndex];
      return SafeArea(
        child: Stack(
          children: <Widget>[
            PhotoViewGallery.builder(
              itemCount: state.model.mediaPosts.length,
              builder: (context, index) {
                return _buildCarouselItem(context, state.model.mediaPosts[index]);
              },
              scrollPhysics: BouncingScrollPhysics(),
              backgroundDecoration: BoxDecoration(color: Colors.transparent),
              loadingBuilder: (context, index) => Constants.progressIndicator,
              pageController: PageController(initialPage: state.selectedMediaIndex),
              onPageChanged: ((pageIndex) {
                if (pageIndex != state.selectedMediaIndex) {
                  _threadDetailBloc.add(ThreadDetailEventOnPostSelected(pageIndex, null));
                }
              }),
            ),
            _buildBottomView(post),
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
      return BasePageState.buildErrorScreen(context, (state as ChanStateError)?.message);
    }
  }

  PhotoViewGalleryPageOptions _buildCarouselItem(BuildContext context, PostItem post) {
    if (post.hasImage() || post.hasGif()) {
      return PhotoViewGalleryPageOptions(
        imageProvider: ChanNetworkImage(post.getImageUrl(), null, post.getCacheDirective()),
        heroAttributes: PhotoViewHeroAttributes(tag: post.getMediaUrl()),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
      );
    } else if (post.hasWebm()) {
      return PhotoViewGalleryPageOptions.customChild(
        child: ChanVideoPlayer(post: post),
        heroAttributes: PhotoViewHeroAttributes(tag: post.getMediaUrl()),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
      );
    } else {
      return null;
    }
  }

  Widget _buildBottomView(PostItem post) {
    double initialChildSize = post.hasMedia() ? 0.05 : 0.2;
    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: 0.05,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        List<PostItem> allPosts = [post, ...post.repliesFrom];
        return Material(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 2.0),
            shrinkWrap: true,
            controller: scrollController,
            itemCount: allPosts.length,
            itemBuilder: (context, index) {
              PostItem replyPost = allPosts[index];
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(top: 2.0, bottom: 8.0),
                  child: PostListWidget(
                    post: replyPost,
                    showAsHeader: true,
                    showHeroAnimation: false,
                    onLinkTap: (url) => _onLinkClicked(context, url),
                  ),
                );
              } else {
                return PostListWidget(
                  post: replyPost,
                  showHeroAnimation: false,
                  onTap: () => _onReplyPostClicked(context, replyPost),
                  onLinkTap: (url) => _onLinkClicked(context, url),
                );
              }
            },
          ),
        );
      },
    );
  }

  void _onReplyPostClicked(BuildContext context, PostItem replyPost) {
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => BlocProvider.value(
              value: _threadDetailBloc,
              child: GalleryPage(showAsReply: true, selectedPostId: replyPost.postId),
            )));

//    showDialog(
//      context: context,
//      child: Dialog(
//        child: BlocProvider(
//          create: (context) => ThreadDetailBloc(
//            replyPost.boardId,
//            replyPost.threadId,
//            false,
//            false,
//            false,
//            replyPost.postId,
//          ),
//          child: ThreadDetailPage(),
//        ),
//        insetPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
//      ),
//    );
  }

  void _onLinkClicked(BuildContext context, String url) => _threadDetailBloc.add(ThreadDetailEventOnReplyClicked(ChanUtil.getPostIdFromUrl(url)));
}
