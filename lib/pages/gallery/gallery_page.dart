import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/gallery/bloc/gallery_bloc.dart';
import 'package:flutter_chan_viewer/pages/gallery/bloc/gallery_event.dart';
import 'package:flutter_chan_viewer/pages/gallery/bloc/gallery_state.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/dialog_util.dart';
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
        BlocConsumer<GalleryBloc, ChanState>(listener: (context, state) {
          if (state is GalleryStateContent && state.event != null) {
            switch (state.event) {
              case GallerySingleEvent.SHOW_COLLECTIONS_DIALOG:
                List<ThreadItem> threads = state.customThreads;
                DialogUtil.showCustomCollectionPickerDialog(
                  context,
                  threads,
                  _newCollectionTextController,
                  (context, name) => {bloc.add(GalleryEventCreateNewCollection(name))},
                  (context, name) {
                    bloc.add(GalleryEventAddPostToCollection(name, state.selectedPost!.postId));
                  },
                );
                break;
              case GallerySingleEvent.SHOW_POST_ADDED_TO_COLLECTION_SUCCESS:
                showPostAddedToCollectionSuccessSnackbar(context);
                break;
              case ChanSingleEvent.SHOW_OFFLINE:
                showOfflineSnackbar(context);
                break;
              default:
                break;
            }
          }
        }, builder: (context, state) {
          return BlocBuilder<GalleryBloc, ChanState>(
            bloc: bloc as GalleryBloc?,
            builder: (context, state) {
              if (state is ChanStateLoading) {
                return Constants.centeredProgressIndicator;
              } else if (state is GalleryStateContent) {
                if (widget.showAsReply) {
                  return _buildSinglePostBody(context, state, state.selectedPost!);
                } else {
                  PostItem? post = state.selectedPost;
                  if (post == null) {
                    return Constants.noDataPlaceholder;
                  } else if (post.hasMedia()) {
                    return _buildCarouselBody(context, state, post);
                  } else {
                    return _buildSinglePostBody(context, state, post);
                  }
                }
              } else {
                return BasePageState.buildErrorScreen(context, (state as ChanStateError).message);
              }
            },
          );
        }),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5));
  }

  Widget _buildSinglePostBody(BuildContext context, GalleryStateContent state, PostItem post) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          _buildSinglePostItem(context, post),
          _buildBottomView(post),
        ],
      ),
    );
  }

  Widget _buildSinglePostItem(BuildContext context, PostItem post) {
    if (post.isImage()) {
      return Center(child: ChanCachedImage(post: post, boxFit: BoxFit.fitWidth));
    } else if (post.isWebm()) {
      return _buildVideoPlayer(post);
    } else {
      return Container();
    }
  }

  Widget _buildCarouselBody(BuildContext context, GalleryStateContent state, PostItem post) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          PhotoViewGallery.builder(
            itemCount: state.posts.length,
            builder: (context, index) {
              return _buildCarouselItem(context, state.posts[index])!;
            },
            scrollPhysics: BouncingScrollPhysics(),
            backgroundDecoration: BoxDecoration(color: Colors.transparent),
            loadingBuilder: (context, index) => Constants.progressIndicator,
            pageController: PageController(initialPage: state.selectedPostIndex, keepPage: false),
            allowImplicitScrolling: false,
            onPageChanged: ((newMediaIndex) {
              if (newMediaIndex != state.selectedPostIndex) {
                PostItem item = state.posts[newMediaIndex];
                bloc.add(GalleryEventOnPostSelected(item.postId));
                _panelController.close();
              }
            }),
          ),
          _buildBottomView(post),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                "${state.selectedPostIndex + 1}/${state.posts.length} ${post.filename}${post.extension}",
                style: Theme.of(context).textTheme.caption,
              ),
            ),
          ),
        ],
      ),
    );
  }

  PhotoViewGalleryPageOptions? _buildCarouselItem(BuildContext context, PostItem post) {
    if (!post.hasMedia()) {
      return null;
    }

    return PhotoViewGalleryPageOptions.customChild(
      child: post.isImage() ? ChanCachedImage(post: post, boxFit: BoxFit.contain) : _buildVideoPlayer(post),
      heroAttributes: PhotoViewHeroAttributes(tag: post.getMediaUrl()!),
      controller: _photoViewController,
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 32,
      tightMode: false,
      disableGestures: false,
    );
  }

  Widget _buildVideoPlayer(PostItem post) {
    if (ChanUtil.isMobile()) {
      return ChanVideoPlayer(post: post);
    } else {
      return ChanVideoPlayerVlc(post: post);
    }
  }

  Widget _buildBottomView(PostItem post) {
    List<PostItem> repliesPosts = [post, ...post.visibleReplies];

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
            _buildBottomViewHeader(repliesPosts[0]),
            Expanded(
              child: Material(
                child: ListView.builder(
                  controller: sc,
                  shrinkWrap: true,
                  // physics: ClampingScrollPhysics(),
                  itemCount: repliesPosts.length,
                  itemBuilder: (context, index) {
                    PostItem replyPost = repliesPosts[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: PostListWidget(
                        post: replyPost,
                        showHeroAnimation: false,
                        showImage: index != 0,
                        onTap: () => index != 0 ? _onReplyPostClicked(context, replyPost) : null,
                        onLongPress: () => _showReplyDetailDialog(context, replyPost),
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
      // panel: Column(
      //   crossAxisAlignment: CrossAxisAlignment.end,
      //   children: [
      //     _buildBottomViewHeader(repliesPosts[0]),
      //     Material(
      //       child: ListView.builder(
      //         shrinkWrap: true,
      //         physics: NeverScrollableScrollPhysics(),
      //         itemCount: repliesPosts.length,
      //         itemBuilder: (context, index) {
      //           PostItem replyPost = repliesPosts[index];
      //           return Padding(
      //             padding: const EdgeInsets.symmetric(horizontal: 2.0),
      //             child: PostListWidget(
      //               post: replyPost,
      //               showHeroAnimation: false,
      //               showImage: index != 0,
      //               onTap: () => index != 0 ? _onReplyPostClicked(context, replyPost) : null,
      //               onLongPress: () => _showReplyDetailDialog(context, replyPost),
      //               onLinkTap: (url) => _onLinkClicked(context, url),
      //               selected: false,
      //             ),
      //           );
      //         },
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  Widget _buildBottomViewHeader(PostItem post) {
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
                child: Text("${post.visibleReplies.length} replies", style: Theme.of(context).textTheme.caption),
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
                IconButton(icon: Icon(Icons.visibility_off), onPressed: () => _onHidePostClicked(context, post)),
                IconButton(icon: Icon(Icons.add), onPressed: () => _onCollectionsClicked(context, post)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onReplyPostClicked(BuildContext context, PostItem replyPost) {
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) {
          return BlocProvider(
            create: (context) => GalleryBloc(replyPost.boardId, replyPost.threadId, replyPost.postId),
            child: GalleryPage(showAsReply: true),
          );
        }));
  }

  void _onLinkClicked(BuildContext context, String url) =>
      bloc.add(GalleryEventOnReplyClicked(ChanUtil.getPostIdFromUrl(url)));

  void _onHidePostClicked(BuildContext context, PostItem post) => bloc.add(GalleryEventHidePost(post.postId));

  void _onCollectionsClicked(BuildContext context, PostItem post) {
    if (bloc.state is GalleryStateContent) {
      List<ThreadItem> threads = bloc.state.customThreads;
      DialogUtil.showCustomCollectionPickerDialog(
        context,
        threads,
        _newCollectionTextController,
        (context, name) => {bloc.add(GalleryEventCreateNewCollection(name))},
        (context, name) => {bloc.add(GalleryEventAddPostToCollection(name, post.postId))},
      );
    }
  }

  void showPostAddedToCollectionSuccessSnackbar(BuildContext context) {
    final snackBar = SnackBar(content: Text("Post added to collection."));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showReplyDetailDialog(BuildContext context, PostItem replyPost) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Choose action'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                bloc.add(GalleryEventHidePost(replyPost.postId));
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
