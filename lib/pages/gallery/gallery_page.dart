import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/models/chan_post.dart';
import 'package:flutter_chan_viewer/navigation/navigation_helper.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/bloc/thread_detail_event.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/thread_detail_page.dart';
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
    _threadDetailBloc = BlocProvider.of<ThreadDetailBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThreadDetailBloc, ThreadDetailState>(
        bloc: _threadDetailBloc,
        builder: (context, state) => buildScaffold(
              context,
              buildBody(context, state),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
            ));
  }

  Widget buildBody(BuildContext context, ThreadDetailState state) {
    if (state is ThreadDetailStateLoading) {
      return Constants.centeredProgressIndicator;
    }
    if (state is ThreadDetailStateContent) {
      int mediaIndex = state.selectedMediaIndex;
      if (mediaIndex < 0) { // for case when non-media post is selected
        return Constants.noDataPlaceholder;
      }

      ChanPost post = state.model.mediaPosts[mediaIndex];
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
              loadingBuilder: (context, index) => Constants.progressIndicator,
              pageController: PageController(initialPage: state.selectedMediaIndex),
              onPageChanged: ((pageIndex) {
                if (pageIndex != state.selectedMediaIndex) {
                  _threadDetailBloc.add(ThreadDetailEventOnPostSelected(pageIndex, null));
                }
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
    if (post.hasImage() || post.hasGif()) {
      return PhotoViewGalleryPageOptions(
        imageProvider: ChanNetworkImage(post.getImageUrl(), post.getCacheDirective()),
        heroAttributes: PhotoViewHeroAttributes(tag: post.getMediaUrl()),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
      );
    } else if (post.hasWebm()) {
      return PhotoViewGalleryPageOptions.customChild(
        child: ChanVideoPlayer(post),
        heroAttributes: PhotoViewHeroAttributes(tag: post.getMediaUrl()),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
      );
    } else {
      return null;
    }
  }

  Widget _buildBottomView(ChanPost post) {
    return DraggableScrollableSheet(
      initialChildSize: 0.05,
      minChildSize: 0.05,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: Material(
            child: ListView.builder(
              padding: EdgeInsets.all(4),
              shrinkWrap: true,
              controller: scrollController,
              itemCount: post.repliesFrom.length,
              itemBuilder: (context, index) {
                return PostListWidget(post.repliesFrom[index], false, false, () => _onReplyPostClicked(post.repliesFrom[index], context), (url) => _onLinkClicked(url, context));
              },
            ),
          ),
        );
      },
    );
  }

  void _onReplyPostClicked(ChanPost post, BuildContext context) {
    showDialog(
        context: context,
        child: Dialog(
            child: BlocProvider(
                create: (context) => ThreadDetailBloc(
                      post.boardId,
                      post.threadId,
                      true,
                      false,
                      false,
                      post.postId,
                    ),
                child: ThreadDetailPage())));

//    _threadDetailBloc.add(ThreadDetailEventOnReplyClicked(post.postId));
//    Navigator.of(context).pop();
  }

  void _onLinkClicked(String url, BuildContext context) => _threadDetailBloc.add(ThreadDetailEventOnReplyClicked(ChanUtil.getPostIdFromUrl(url)));
}
