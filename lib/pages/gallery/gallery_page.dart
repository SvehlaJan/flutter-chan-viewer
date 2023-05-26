import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/models/ui/post_item_vo.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item_vo.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/gallery/bloc/gallery_bloc.dart';
import 'package:flutter_chan_viewer/pages/gallery/bloc/gallery_event.dart';
import 'package:flutter_chan_viewer/pages/gallery/bloc/gallery_state.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/dialog_util.dart';
import 'package:flutter_chan_viewer/utils/media_helper.dart';
import 'package:flutter_chan_viewer/view/list_widget_post.dart';
import 'package:flutter_chan_viewer/view/view_cached_image.dart';
import 'package:flutter_chan_viewer/view/view_video_player.dart';
import 'package:flutter_chan_viewer/view/view_video_player_vlc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class GalleryPage extends StatefulWidget {
  final bool showAsReply;

  const GalleryPage({
    required this.showAsReply,
  });

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends BasePageState<GalleryPage> {
  late PanelController _panelController;
  late PhotoViewController _photoViewController;
  TextEditingController? _newCollectionTextController;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<GalleryBloc>(context);
    bloc.add(ChanEventInitBloc());

    _newCollectionTextController = TextEditingController();
    _panelController = PanelController();
    _photoViewController = PhotoViewController();

    if (widget.showAsReply) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _panelController.open();
      });
    }
  }

  @override
  Future<bool> onBackPressed() {
    if (_panelController.isPanelOpen) {
      _panelController.close();
      // if (widget.showAsReply) {
      return Future.delayed(const Duration(milliseconds: 100), () {
        return Future.value(true);
      });
      // } else {
      //   return Future.value(false);
      // }
    } else {
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildScaffold(
        context,
        BlocConsumer<GalleryBloc, GalleryState>(
          listener: (context, state) {
            if (state is GalleryStateContent && state.galleryEvent != null) {
              switch (state.galleryEvent) {
                case GallerySingleEventShowCollectionsDialog _:
                  var event = state.galleryEvent as GallerySingleEventShowCollectionsDialog;
                  DialogUtil.showCustomCollectionPickerDialog(
                    context,
                    event.customThreads,
                    _newCollectionTextController,
                    (context, name) => {bloc.add(GalleryEventCreateNewCollection(name))},
                    (context, name) {
                      bloc.add(GalleryEventAddPostToCollection(name, event.selectedPostId));
                    },
                  );
                  break;
                case GallerySingleEventShowPostAddedToCollectionSuccess _:
                  showPostAddedToCollectionSuccessSnackbar(context);
                  break;
                case GallerySingleEventShowOffline _:
                  showOfflineSnackbar(context);
                  break;
                case GallerySingleEventShowReply _:
                  var event = state.galleryEvent as GallerySingleEventShowReply;
                  Navigator.of(context).push(PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (_, __, ___) {
                        return BlocProvider(
                          create: (context) => GalleryBloc(event.boardId, event.threadId, event.postId),
                          child: GalleryPage(showAsReply: true),
                        );
                      }));
                default:
                  break;
              }
            }
          },
          builder: (context, state) {
            return BlocBuilder<GalleryBloc, GalleryState>(
              bloc: bloc as GalleryBloc?,
              builder: (context, state) {
                switch (state) {
                  case GalleryStateLoading _:
                    return Constants.centeredProgressIndicator;
                  case GalleryStateContent _:
                    if (widget.showAsReply || state.selectedPost.mediaSource == null) {
                      return _buildSinglePostBody(
                        context,
                        state.selectedPost.mediaSource,
                        state.replies,
                      );
                    } else {
                      return _buildCarouselBody(
                        context,
                        state.mediaSources,
                        state.initialPostIndex,
                        state.selectedPostIndex,
                        state.selectedPost,
                        state.replies,
                      );
                    }
                  case GalleryStateError _:
                    return BasePageState.buildErrorScreen(context, state.message);
                }
              },
            );
          },
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5));
  }

  Widget _buildSinglePostBody(
    BuildContext context,
    MediaSource? mediaSource,
    List<PostItemVO> replies,
  ) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          if (mediaSource != null) _buildSinglePostContent(context, mediaSource),
          _buildBottomView(context, replies),
        ],
      ),
    );
  }

  Widget _buildSinglePostContent(BuildContext context, MediaSource? mediaSource) {
    switch (mediaSource) {
      case VideoSource _:
        return _buildVideoPlayer(mediaSource);
      case ImageSource _:
        return Center(child: ChanCachedImage(imageSource: mediaSource, boxFit: BoxFit.fitWidth));
      default:
        return Container();
    }
  }

  Widget _buildCarouselBody(
    BuildContext context,
    List<MediaSource> mediaSources,
    int initialPostIndex,
    int selectedPostIndex,
    PostItemVO post,
    List<PostItemVO> replies,
  ) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          _buildCarouselContent(context, mediaSources, initialPostIndex),
          _buildBottomView(context, replies),
          _buildCarouselOverlay(context, mediaSources, selectedPostIndex, post.fileName),
        ],
      ),
    );
  }

  Widget _buildCarouselContent(
    BuildContext context,
    List<MediaSource> mediaSources,
    int initialPostIndex,
  ) {
    return PhotoViewGallery.builder(
      itemCount: mediaSources.length,
      builder: (context, index) {
        return _buildCarouselItem(context, mediaSources[index])!;
      },
      scrollPhysics: BouncingScrollPhysics(),
      backgroundDecoration: BoxDecoration(color: Colors.transparent),
      loadingBuilder: (context, index) => Constants.progressIndicator,
      pageController: PageController(initialPage: initialPostIndex, keepPage: false),
      allowImplicitScrolling: false,
      onPageChanged: ((newMediaIndex) {
        if (newMediaIndex != initialPostIndex) {
          MediaSource item = mediaSources[newMediaIndex];
          bloc.add(GalleryEventOnPostSelected(item.postId));
          _panelController.close();
        }
      }),
    );
  }

  Widget _buildCarouselOverlay(
    BuildContext context,
    List<MediaSource> mediaSources,
    int selectedPostIndex,
    String? fileName,
  ) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          "${selectedPostIndex + 1}/${mediaSources.length} ${fileName}",
          style: Theme.of(context).textTheme.caption,
        ),
      ),
    );
  }

  PhotoViewGalleryPageOptions? _buildCarouselItem(BuildContext context, MediaSource mediaSource) {
    late Widget child;
    switch (mediaSource) {
      case VideoSource _:
        child = _buildVideoPlayer(mediaSource);
        break;
      case ImageSource _:
        child = ChanCachedImage(imageSource: mediaSource, boxFit: BoxFit.contain);
        break;
    }
    return PhotoViewGalleryPageOptions.customChild(
      child: child,
      heroAttributes: PhotoViewHeroAttributes(tag: mediaSource.postId),
      controller: _photoViewController,
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 32,
      tightMode: false,
      disableGestures: false,
    );
  }

  Widget _buildVideoPlayer(VideoSource videoSource) {
    if (ChanUtil.isMobile()) {
      return ChanVideoPlayer(videoSource: videoSource);
    } else {
      return ChanVideoPlayerVlc(videoSource: videoSource);
    }
  }

  Widget _buildBottomView(BuildContext context, List<PostItemVO> replies) {
    return SlidingUpPanel(
      controller: _panelController,
      defaultPanelState: PanelState.CLOSED,
      minHeight: 64,
      maxHeight: MediaQuery.of(context).size.height * 0.8,
      renderPanelSheet: false,
      isDraggable: true,
      // panelSnapping: true,
      // collapsed: _buildBottomViewHeader(post),
      panelBuilder: (sc) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildBottomViewHeader(replies.length, replies.first.postId),
            Expanded(
              child: Material(
                child: ListView.builder(
                  controller: sc,
                  shrinkWrap: true,
                  // physics: ClampingScrollPhysics(),
                  itemCount: replies.length,
                  itemBuilder: (context, index) {
                    PostItemVO replyPost = replies[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: PostListWidget(
                        post: replyPost,
                        showHeroAnimation: false,
                        showImage: index != 0,
                        onTap: () => index != 0 ? _onReplyPostClicked(context, replyPost.postId) : null,
                        onLongPress: () => _showReplyDetailDialog(context, replyPost.postId),
                        onLinkTap: (url) => _onLinkClicked(context, url),
                        selected: false,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomViewHeader(int repliesCount, int postId) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0, left: 2.0, right: 2.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          InkWell(
            onTap: () => _panelController.open(),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.0),
                  topRight: Radius.circular(4.0),
                ),
              ),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text("${repliesCount} replies", style: Theme.of(context).textTheme.caption),
              ),
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4.0),
                bottomLeft: Radius.circular(4.0),
                bottomRight: Radius.circular(4.0),
              ),
            ),
            margin: EdgeInsets.zero,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Icons.visibility_off), onPressed: () => _onHidePostClicked(context, postId)),
                IconButton(icon: Icon(Icons.add), onPressed: () => _onCollectionsClicked(context, postId)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onReplyPostClicked(BuildContext context, int postId) {
    bloc.add(GalleryEventOnReplyClicked(postId));
  }

  void _onLinkClicked(BuildContext context, String url) =>
      bloc.add(GalleryEventOnReplyClicked(ChanUtil.getPostIdFromUrl(url)));

  void _onHidePostClicked(BuildContext context, int postId) => bloc.add(GalleryEventHidePost(postId));

  void _onCollectionsClicked(BuildContext context, int postId) {
    if (bloc.state is GalleryStateContent) {
      List<ThreadItemVO> threads = bloc.state.customThreads;
      DialogUtil.showCustomCollectionPickerDialog(
        context,
        threads,
        _newCollectionTextController,
        (context, name) => {bloc.add(GalleryEventCreateNewCollection(name))},
        (context, name) => {bloc.add(GalleryEventAddPostToCollection(name, postId))},
      );
    }
  }

  void showPostAddedToCollectionSuccessSnackbar(BuildContext context) {
    final snackBar = SnackBar(content: Text("Post added to collection."));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showReplyDetailDialog(BuildContext context, int postId) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Choose action'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                bloc.add(GalleryEventHidePost(postId));
                Navigator.of(context).pop();
              },
              child: const Text('Hide reply'),
            ),
          ],
        );
      },
    );
  }
}
