import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/bloc/thread_detail_event.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/view/list_widget_post.dart';
import 'package:flutter_chan_viewer/view/network_image/chan_networkimage.dart';
import 'package:flutter_chan_viewer/view/view_cached_image.dart';
import 'package:flutter_chan_viewer/view/view_video_player.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

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
  ThreadDetailBloc _threadDetailBloc;
  SheetController _sheetController;
  TextEditingController _newCollectionTextController;

  @override
  void initState() {
    super.initState();
    _threadDetailBloc = BlocProvider.of<ThreadDetailBloc>(context);
    _newCollectionTextController = TextEditingController();
    _sheetController = SheetController.of(context) ?? SheetController();
    if (widget.showAsReply) {
      _sheetController.expand();
    }
  }

  @override
  Future<bool> onBackPressed() {
    if (_sheetController?.state?.isExpanded ?? false) {
      _sheetController.collapse();
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
                showCustomCollectionPickerDialog(context);
                break;
              case ThreadDetailSingleEvent.SHOW_POST_ADDED_TO_COLLECTION_SUCCESS:
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
            cubit: _threadDetailBloc,
            builder: (context, state) => widget.showAsReply ? _buildSinglePostBody(context, state, widget.selectedPostId) : _buildCarouselBody(context, state),
          );
        }),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5));
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
                  "${state.selectedMediaIndex + 1}/${state.model.mediaPosts.length} ${post.filename}${post.extension}",
                  style: Theme.of(context).textTheme.caption,
                ),
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
    List<PostItem> allPosts = [post, ...post.repliesFrom];

    return SlidingSheet(
      elevation: 4,
      cornerRadius: 0,
      controller: _sheetController,
      duration: Duration(milliseconds: 200),
      snapSpec: const SnapSpec(
        snap: false,
        snappings: [20, 1000],
        positioning: SnapPositioning.pixelOffset,
      ),
      builder: (context, state) {
        return Material(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 2.0),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: allPosts.length,
            itemBuilder: (context, index) {
              PostItem replyPost = allPosts[index];
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(top: 2.0, bottom: 4.0),
                  child: Column(
                    children: [
                      PostListWidget(
                        post: replyPost,
                        showAsHeader: true,
                        showHeroAnimation: false,
                        onLinkTap: (url) => _onLinkClicked(context, url),
                      ),
                      _buildControlPanel(context),
                    ],
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
  }

  void _onLinkClicked(BuildContext context, String url) => _threadDetailBloc.add(ThreadDetailEventOnReplyClicked(ChanUtil.getPostIdFromUrl(url)));

  void _onHidePostClicked(BuildContext context) => _threadDetailBloc.add(ThreadDetailEventHidePost());

  void _onAddPostToCollectionClicked(BuildContext context, String name) => _threadDetailBloc.add(ThreadDetailEventAddPostToCollection(name));

  void _onCreateNewCollectionClicked(BuildContext context, String name) => _threadDetailBloc.add(ThreadDetailEventCreateNewCollection(name));

  Widget _buildControlPanel(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.symmetric(horizontal: 2.0),
      child: Row(
        children: [
          IconButton(icon: Icon(Icons.visibility_off), onPressed: () => _onHidePostClicked(context)),
          IconButton(icon: Icon(Icons.add), onPressed: () => showCustomCollectionPickerDialog(context)),
        ],
      ),
    );
  }

  void showPostAddedToCollectionSuccessSnackbar(BuildContext context) {
    final snackBar = SnackBar(content: Text("Post added to collection."));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void showCustomCollectionPickerDialog(BuildContext context) {
    List<Widget> items = _threadDetailBloc.customThreads
        .map((thread) => ListTile(
              title: Text(thread.subtitle),
              onTap: () {
                _onAddPostToCollectionClicked(context, thread.subtitle);
                Navigator.of(context).pop();
              },
            ))
        .toList();
    items.add(ListTile(
      title: TextField(
        controller: _newCollectionTextController,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(hintText: "New collection"),
      ),
      trailing: IconButton(
        icon: Icon(Icons.add),
        onPressed: () {
          String name = _newCollectionTextController.text;
          _newCollectionTextController.clear();
          _onCreateNewCollectionClicked(context, name);
          Navigator.of(context).pop();
        },
      ),
    ));

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text("Add post to collection"),
            children: items,
          );
        });
  }
}
