import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

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

class _GalleryPageState extends BasePageState<GalleryPage>
    with TickerProviderStateMixin {
  SheetController _sheetController;
  TextEditingController _newCollectionTextController;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<ThreadDetailBloc>(context);
    _newCollectionTextController = TextEditingController();
    _sheetController = SheetController.of(context) ?? SheetController();
    if (widget.showAsReply) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _sheetController.expand();
      });
    }
  }

  @override
  Future<bool> onBackPressed() {
    if (_sheetController?.state?.isExpanded ?? false) {
      _sheetController.collapse();
      if (widget.showAsReply) {
        return Future.delayed(const Duration(milliseconds: 200), () {
          return Future.value(true);
        });
      }
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return buildScaffold(
        context,
        BlocConsumer<ThreadDetailBloc, ChanState>(listener: (context, state) {
          if (state is ThreadDetailStateContent && state.event != null) {
            switch (state.event) {
              case ThreadDetailSingleEvent.SHOW_COLLECTIONS_DIALOG:
                List<ThreadItem> threads = bloc.state.customThreads;
                DialogUtil.showCustomCollectionPickerDialog(
                  context,
                  threads,
                  _newCollectionTextController,
                  _onCreateNewCollectionClicked,
                  _onAddPostToCollectionClicked,
                );
                break;
              case ThreadDetailSingleEvent
                  .SHOW_POST_ADDED_TO_COLLECTION_SUCCESS:
                showPostAddedToCollectionSuccessSnackbar(context);
                break;
              case ThreadDetailSingleEvent.SHOW_OFFLINE:
                showOfflineSnackbar(context);
                break;
              default:
                break;
            }
          }
        }, builder: (context, state) {
          return BlocBuilder<ThreadDetailBloc, ChanState>(
            cubit: bloc,
            builder: (context, state) => widget.showAsReply
                ? _buildSinglePostBody(context, state, widget.selectedPostId)
                : _buildCarouselBody(context, state),
          );
        }),
        backgroundColor:
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5));
  }

  Widget _buildSinglePostBody(
      BuildContext context, ChanState state, int postId) {
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
      return BasePageState.buildErrorScreen(
          context, (state as ChanStateError)?.message);
    }
  }

  Widget _buildSinglePostItem(BuildContext context, PostItem post) {
    if (post.hasImage()) {
      return Center(
          child: ChanCachedImage(post: post, boxFit: BoxFit.fitWidth));
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

      PostItem post = state.model.visibleMediaPosts[mediaIndex];
      return SafeArea(
        child: Stack(
          children: <Widget>[
            PhotoViewGallery.builder(
              itemCount: state.model.visibleMediaPosts.length,
              builder: (context, index) {
                return _buildCarouselItem(
                    context, state.model.visibleMediaPosts[index]);
              },
              scrollPhysics: BouncingScrollPhysics(),
              backgroundDecoration: BoxDecoration(color: Colors.transparent),
              loadingBuilder: (context, index) => Constants.progressIndicator,
              pageController:
                  PageController(initialPage: state.selectedMediaIndex),
              onPageChanged: ((newMediaIndex) {
                if (newMediaIndex != state.selectedMediaIndex) {
                  bloc.add(
                      ThreadDetailEventOnPostSelected(newMediaIndex, null));
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
    } else {
      return BasePageState.buildErrorScreen(
          context, (state as ChanStateError)?.message);
    }
  }

  PhotoViewGalleryPageOptions _buildCarouselItem(
      BuildContext context, PostItem post) {
    if (!post.hasMedia()) {
      return null;
    }

    return PhotoViewGalleryPageOptions.customChild(
      child: post.hasImage()
          ? ChanCachedImage(post: post, boxFit: BoxFit.contain)
          : ChanVideoPlayer(post: post),
      heroAttributes: PhotoViewHeroAttributes(tag: post.getMediaUrl()),
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained * 0.8,
      maxScale: PhotoViewComputedScale.covered * 32,
      disableGestures: false,
    );
  }

  Widget _buildBottomView(PostItem post) {
    List<PostItem> repliesPosts = [post, ...post.repliesFrom];

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
                        onTap: () => index != 0
                            ? _onReplyPostClicked(context, replyPost)
                            : null,
                        onLongPress: null,
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
                child: Text("${post.repliesFrom.length} replies",
                    style: Theme.of(context).textTheme.caption),
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
                IconButton(
                    icon: Icon(Icons.visibility_off),
                    onPressed: () => _onHidePostClicked(context)),
                IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => _onCollectionsClicked(context)),
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
              child: GalleryPage(
                  showAsReply: true, selectedPostId: replyPost.postId),
            )));
  }

  void _onLinkClicked(BuildContext context, String url) =>
      bloc.add(ThreadDetailEventOnReplyClicked(ChanUtil.getPostIdFromUrl(url)));

  void _onHidePostClicked(BuildContext context) =>
      bloc.add(ThreadDetailEventHidePost());

  void _onCollectionsClicked(BuildContext context) {
    if (bloc.state is ThreadDetailStateContent) {
      List<ThreadItem> threads = bloc.state.customThreads;
      DialogUtil.showCustomCollectionPickerDialog(
        context,
        threads,
        _newCollectionTextController,
        _onCreateNewCollectionClicked,
        _onAddPostToCollectionClicked,
      );
    }
  }

  void _onAddPostToCollectionClicked(BuildContext context, String name) =>
      bloc.add(ThreadDetailEventAddPostToCollection(name));

  void _onCreateNewCollectionClicked(BuildContext context, String name) =>
      bloc.add(ThreadDetailEventCreateNewCollection(name));

  void showPostAddedToCollectionSuccessSnackbar(BuildContext context) {
    final snackBar = SnackBar(content: Text("Post added to collection."));
    Scaffold.of(context).showSnackBar(snackBar);
  }
}
