import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/app_bloc/app_bloc.dart';
import 'package:flutter_chan_viewer/bloc/app_bloc/app_event.dart';
import 'package:flutter_chan_viewer/models/posts_model.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/bloc/thread_detail_event.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/view/view_cached_image.dart';
import 'package:flutter_chan_viewer/view/view_custom_carousel.dart';
import 'package:flutter_chan_viewer/view/view_video_player.dart';

import '../thread_detail/bloc/thread_detail_bloc.dart';
import '../thread_detail/bloc/thread_detail_state.dart';

class GalleryPage extends StatefulWidget {
  static const String ARG_BOARD_ID = "ChanGallery.ARG_BOARD_ID";
  static const String ARG_THREAD_ID = "ChanGallery.ARG_THREAD_ID";
  static const String ARG_POST_ID = "ChanGallery.ARG_POST_ID";
  static const bool enableInfiniteScroll = true;

  final String boardId;
  final int threadId;
  final int postId;

//  final PageController pageController;

  static Map<String, dynamic> getArguments(final String boardId, final int threadId, final int postId) =>
      {GalleryPage.ARG_BOARD_ID: boardId, GalleryPage.ARG_THREAD_ID: threadId, GalleryPage.ARG_POST_ID: postId};

  GalleryPage(this.boardId, this.threadId, this.postId);

//  : this.pageController = PageController(initialPage: CustomCarousel.getRealPage(enableInfiniteScroll, initialPageIndex));

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> with TickerProviderStateMixin {
  static const int DOUBLE_TAP_TIMEOUT = 300;
  static const double SCALE_MIN = 1.0;
  static const double SCALE_MAX = 10.0;
  static const double IS_SCALED_TRESHOLD = 1.2;
  static const int SCALE_ANIMATION_DURATION = 200;

  ThreadDetailBloc _threadDetailBloc;
  AnimationController _flingAnimationController;
  AnimationController _scaleAnimationController;
  Animation<Offset> _flingAnimation;
  Animation<double> _scaleAnimation;
  Offset _offset = Offset.zero;
  double _currentScale = SCALE_MIN;
  Offset _normalizedOffset;
  Offset _targetOffset;
  double _previousScale;
  int _previousTapTimestamp = 0;
  int currentPageIndex;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AppBloc>(context).dispatch(AppEventShowBottomBar(false));
    _threadDetailBloc = BlocProvider.of<ThreadDetailBloc>(context);
    _threadDetailBloc.dispatch(ThreadDetailEventAppStarted());
    _threadDetailBloc.dispatch(ThreadDetailEventFetchPosts(false, widget.boardId, widget.threadId));
    _flingAnimationController = AnimationController(vsync: this)..addListener(_handleFlingAnimation);
    _scaleAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: SCALE_ANIMATION_DURATION))..addListener(_handleScaleAnimation);
  }

  @override
  void dispose() {
    _threadDetailBloc.dispose();
    _flingAnimationController.dispose();
    super.dispose();
  }

  // The maximum offset value is 0,0. If the size of this renderer's box is w,h
  // then the minimum offset value is w - _scale * w, h - _scale * h.
  Offset _clampOffset(Offset offset) {
    final Size size = context.size;
    final Offset minOffset = Offset(size.width, size.height) * (1.0 - _currentScale);
    return Offset(offset.dx.clamp(minOffset.dx, 0.0), offset.dy.clamp(minOffset.dy, 0.0));
  }

  void _handleFlingAnimation() {
    setState(() {
      _offset = _flingAnimation.value;
    });
  }

  void _handleScaleAnimation() {
    setState(() {
      _currentScale = _scaleAnimation.value;
      _offset = _clampOffset(_targetOffset - _normalizedOffset * _currentScale);
    });
  }

  void _handleOnScaleStart(ScaleStartDetails details) {
    print("Scale start");
    setState(() {
      _previousScale = _currentScale;
      _normalizedOffset = (details.focalPoint - _offset) / _currentScale;
      // The fling animation stops if an input gesture starts.
      _flingAnimationController.stop();
    });
  }

  void _handleOnScaleUpdate(ScaleUpdateDetails details) {
//    print("Scale update { _offset: $_offset, details.focalPoint: ${details.focalPoint}, _normalizedOffset: $_normalizedOffset }");
    setState(() {
      _currentScale = (_previousScale * details.scale).clamp(SCALE_MIN, SCALE_MAX);
      if (_isScaled()) {
        _offset = _clampOffset(details.focalPoint - _normalizedOffset * _currentScale);
      } else {
        _offset = details.focalPoint - _normalizedOffset * _currentScale;
      }

//      double horizontalDelta = _previousOffset.dx - details.focalPoint.dx;
//      double newPosition = widget.pageController.position.pixels + horizontalDelta;
//      _previousOffset = details.focalPoint;
//      print("horizontalDelta: $horizontalDelta newPosition: $newPosition");
//      widget.pageController.jumpTo(newPosition);
    });
  }

  void _handleOnScaleEnd(ScaleEndDetails details) {
    print("Scale end");
    if (!_isScaled()) {
      if (details.velocity.pixelsPerSecond.distance >= Constants.minFlingDistance) {
        final direction = details.velocity.pixelsPerSecond.direction;
        print("{ direction: $direction }");
        if (direction >= (-pi * 3 / 4) && direction <= (-pi / 4)) {
          Navigator.of(context).pop(false);
          return;
        }
      }

      startFlingBackAnimation(details.velocity.pixelsPerSecond);
    }
  }

  void _handleOnDoubleTap(TapUpDetails details) {
    if (DateTime.now().millisecondsSinceEpoch - _previousTapTimestamp < DOUBLE_TAP_TIMEOUT) {
      print("DoubleTap! ${details.toString()}");

      setState(() {
        _previousScale = _currentScale;
        _targetOffset = details.localPosition;
        _normalizedOffset = (_targetOffset - _offset) / _currentScale;
        startScaleAnimation((_currentScale < 3.0) ? 7.5 : SCALE_MIN);
      });
    }
    _previousTapTimestamp = DateTime.now().millisecondsSinceEpoch;
  }

  bool _isScaled() {
    return _currentScale >= IS_SCALED_TRESHOLD;
  }

  void startFlingBackAnimation(Offset velocity) {
    print("Starting fling back { velocity: $velocity }");
    final Offset direction = velocity / velocity.distance;
    final double distance = (Offset.zero & context.size).shortestSide;
    _flingAnimation = _flingAnimationController.drive(Tween<Offset>(
      begin: _offset,
      end: _clampOffset(_offset + direction * distance),
    ));
    _flingAnimationController
      ..value = 0.0
      ..fling(velocity: velocity.distance / 1000.0);
  }

  void startScaleAnimation(double targetScale) {
    print("animateToScale { targetScale: $targetScale, _scale: $_currentScale");
    _scaleAnimation = _scaleAnimationController.drive(Tween<double>(
      begin: _currentScale,
      end: targetScale,
    ));
    _scaleAnimationController
      ..value = 0.0
      ..forward();
  }

//  void _handleOnHorizontalDragUpdate(DragUpdateDetails details) {
//    print("_handleOnHorizontalDragUpdate { _isScaled: ${_isScaled()} }");
//    if (!_isScaled()) {
//      setState(() {
//        widget.pageController.jumpTo(widget.pageController.position.pixels - details.delta.dx);
//      });
//    }
//  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThreadDetailBloc, ThreadDetailState>(
        bloc: _threadDetailBloc,
        builder: (context, state) {
          if (state is ThreadDetailStateLoading) {
            return Center(
              child: Constants.progressIndicator,
            );
          }
          if (state is ThreadDetailStateContent) {
            if (state.data.posts.isEmpty) {
              return Center(
                child: Text('No posts'),
              );
            }

            List<Widget> children = state.data.mediaPosts.map((post) => buildPage(post)).toList();
            int initialIndex = state.data.getMediaIndex(widget.postId);
            return SafeArea(
              child: GestureDetector(
                onScaleStart: _handleOnScaleStart,
                onScaleUpdate: _handleOnScaleUpdate,
                onScaleEnd: _handleOnScaleEnd,
//        onHorizontalDragUpdate: _isScaled() ? null : _handleOnHorizontalDragUpdate,
                onTapUp: _handleOnDoubleTap,
                child: CustomCarousel(
                  items: children,
                  initialPage: initialIndex,
                  enableInfiniteScroll: GalleryPage.enableInfiniteScroll,
                  scrollPhysics: _isScaled() ? NeverScrollableScrollPhysics() : AlwaysScrollableScrollPhysics(),
                  onPageChanged: (int currentPage) {
                    currentPageIndex = currentPage;
                  },
                ),
              ),
            );
          } else {
            return Center(
              child: Text('Failed to fetch posts'),
            );
          }
        });
  }

  Widget buildPage(ChanPost post) {
//    if (currentPage == index) {
    return ClipRect(
      child: Transform(
        transform: Matrix4.identity()
          ..translate(_offset.dx, _offset.dy)
          ..scale(_currentScale),
        child: post.hasImage() ? ChanCachedImage(post.getMediaUrl(), post.getThumbnailUrl()) : ChanVideoPlayer(post, () {}),
      ),
    );
//    } else {
//      return post.hasImage() ? ChanCachedImage(post.getImageUrl(), post.getThumbnailUrl()) : ChanVideoPlayer(post, () {});
//    }
  }
}
