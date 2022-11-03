import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/bloc/thread_detail_bloc.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/bloc/thread_detail_event.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/bloc/thread_detail_state.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/dialog_util.dart';
import 'package:flutter_chan_viewer/view/list_widget_post.dart';
import 'package:flutter_chan_viewer/view/view_cached_image.dart';
import 'package:flutter_chan_viewer/view/view_video_player.dart';
import 'package:flutter_chan_viewer/view/view_video_player_vlc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

class GalleryPage extends StatefulWidget {
  final bool showAsReply;
  final int initialPostId;

  const GalleryPage({
    required this.showAsReply,
    required this.initialPostId,
  });

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends BasePageState<GalleryPage> {
  late SheetController _sheetController;
  late PhotoViewController _photoViewController;
  TextEditingController? _newCollectionTextController;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<ThreadDetailBloc>(context);
    _newCollectionTextController = TextEditingController();
    _sheetController = SheetController.of(context) ?? SheetController();
    _photoViewController = PhotoViewController();

    if (widget.showAsReply) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _sheetController.expand();
      });
    } else {
      bloc.add(ThreadDetailEventOnPostSelected(widget.initialPostId));
    }

    // Future.delayed(const Duration(milliseconds: 100), () {
    //   ThreadDetailStateContent? contentState = bloc.state is ThreadDetailStateContent ? bloc.state : null;
    //   bool hasMedia = contentState?.selectedPost?.hasMedia() ?? false;
    //   if (widget.showAsReply || !hasMedia) {
    //     _sheetController.expand();
    //   }
    // });
  }

  @override
  Future<bool> onBackPressed() {
    if (_sheetController.state?.isExpanded ?? false) {
      _sheetController.collapse();
      // if (widget.showAsReply) {
      return Future.delayed(const Duration(milliseconds: 150), () {
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
        BlocConsumer<ThreadDetailBloc, ChanState>(listener: (context, state) {
          if (state is ThreadDetailStateContent && state.event != null) {
            switch (state.event) {
              case ThreadDetailSingleEvent.SHOW_COLLECTIONS_DIALOG:
                List<ThreadItem> threads = state.customThreads;
                DialogUtil.showCustomCollectionPickerDialog(
                  context,
                  threads,
                  _newCollectionTextController,
                  (context, name) => {bloc.add(ThreadDetailEventCreateNewCollection(name))},
                  (context, name) => {bloc.add(ThreadDetailEventAddPostToCollection(name, state.selectedPostId))},
                );
                break;
              case ThreadDetailSingleEvent.SHOW_POST_ADDED_TO_COLLECTION_SUCCESS:
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
          return BlocBuilder<ThreadDetailBloc, ChanState>(
            bloc: bloc as ThreadDetailBloc?,
            builder: (context, state) {
              if (state is ChanStateLoading) {
                return Constants.centeredProgressIndicator;
              } else if (state is ThreadDetailStateContent) {
                if (widget.showAsReply) {
                  return _buildSinglePostBody(context, state, widget.initialPostId);
                } else {
                  PostItem? post = state.selectedPost;
                  if (post == null) {
                    return Constants.noDataPlaceholder;
                  } else if (post.hasMedia()) {
                    return _buildCarouselBody(context, state, post);
                  } else {
                    return _buildSinglePostBody(context, state, post.postId);
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

  Widget _buildSinglePostBody(BuildContext context, ThreadDetailStateContent state, int postId) {
    PostItem post = state.model.findPostById(postId)!;

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

  Widget _buildCarouselBody(BuildContext context, ThreadDetailStateContent state, PostItem post) {
    int initialMediaIndex = state.model.findPostsMediaIndex(widget.initialPostId);
    return SafeArea(
      child: Stack(
        children: <Widget>[
          PhotoViewGallery.builder(
            itemCount: state.model.visibleMediaPosts.length,
            builder: (context, index) {
              return _buildCarouselItem(context, state.model.visibleMediaPosts[index])!;
            },
            scrollPhysics: BouncingScrollPhysics(),
            backgroundDecoration: BoxDecoration(color: Colors.transparent),
            loadingBuilder: (context, index) => Constants.progressIndicator,
            pageController: PageController(initialPage: initialMediaIndex, keepPage: false),
            allowImplicitScrolling: false,
            onPageChanged: ((newMediaIndex) {
              if (newMediaIndex != state.selectedMediaIndex) {
                PostItem item = state.model.visibleMediaPosts[newMediaIndex];
                bloc.add(ThreadDetailEventOnPostSelected(item.postId));
                _sheetController.collapse();
              }
            }),
          ),
          _buildBottomView(post),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                "${state.selectedMediaIndex + 1}/${state.model.visibleMediaPosts.length} ${post.filename}${post.extension}",
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

    return SlidingSheet(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      controller: _sheetController,
      duration: Duration(milliseconds: 400),
      snapSpec: const SnapSpec(
        snap: false,
        snappings: [20, 1000],
        positioning: SnapPositioning.pixelOffset,
      ),
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildBottomViewHeader(repliesPosts[0]),
            Material(
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
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
            onTap: () => _sheetController.expand(),
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
        pageBuilder: (_, __, ___) => BlocProvider.value(
              value: bloc as ThreadDetailBloc,
              child: GalleryPage(showAsReply: true, initialPostId: replyPost.postId),
            )));
  }

  void _onLinkClicked(BuildContext context, String url) =>
      bloc.add(ThreadDetailEventOnReplyClicked(ChanUtil.getPostIdFromUrl(url)));

  void _onHidePostClicked(BuildContext context, PostItem post) => bloc.add(ThreadDetailEventHidePost(post.postId));

  void _onCollectionsClicked(BuildContext context, PostItem post) {
    if (bloc.state is ThreadDetailStateContent) {
      List<ThreadItem> threads = bloc.state.customThreads;
      DialogUtil.showCustomCollectionPickerDialog(
        context,
        threads,
        _newCollectionTextController,
        (context, name) => {bloc.add(ThreadDetailEventCreateNewCollection(name))},
        (context, name) => {bloc.add(ThreadDetailEventAddPostToCollection(name, post.postId))},
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
                bloc.add(ThreadDetailEventHidePost(replyPost.postId));
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
