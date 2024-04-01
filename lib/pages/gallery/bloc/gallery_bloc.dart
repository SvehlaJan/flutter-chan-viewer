import 'dart:async';
import 'dart:io';

import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/models/ui/post_item_vo.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item_vo.dart';
import 'package:flutter_chan_viewer/repositories/chan_result.dart';
import 'package:flutter_chan_viewer/repositories/posts_repository.dart';
import 'package:flutter_chan_viewer/repositories/threads_repository.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/utils/exceptions.dart';
import 'package:flutter_chan_viewer/utils/log_utils.dart';
import 'package:flutter_chan_viewer/utils/media_helper.dart';

import 'gallery_event.dart';
import 'gallery_state.dart';

class GalleryBloc extends Bloc<ChanEvent, GalleryState> with ChanLogger {
  final ThreadsRepository _threadsRepository = getIt<ThreadsRepository>();
  final PostsRepository _postsRepository = getIt<PostsRepository>();
  final MediaHelper _mediaHelper = getIt<MediaHelper>();
  late final StreamSubscription _subscription;

  final String _boardId;
  final int _threadId;
  final int _initialPostId;
  final bool _showAsReply;

  late ThreadDetailModel _threadDetailModel;
  bool _dataSuccessfullyFetched = false;

  GalleryBloc(
    this._boardId,
    this._threadId,
    this._initialPostId,
    this._showAsReply,
  ) : super(GalleryStateLoading()) {
    _subscription = _threadsRepository.observeThreadDetail(_boardId, _threadId).listen((data) {
      add(ChanEventDataFetched(data));
    }, onError: (e) {
      add(ChanEventDataError(e));
    });

    on<ChanEventInitBloc>((event, emit) async {
      emit(GalleryStateLoading());
    });

    on<ChanEventDataFetched>((event, emit) async {
      if (!_dataSuccessfullyFetched && event.result.data != null) {
        _dataSuccessfullyFetched = true;
      }

      if (event.result is Loading) {
        if (event.result.data != null) {
          _threadDetailModel = event.result.data;
          emit(await buildContentState());
        } else {
          emit(GalleryStateLoading());
        }
      } else if (event.result is Success) {
        _threadDetailModel = event.result.data;
        emit(await buildContentState());
      } else if (event.result is Failure) {
        if (event.result.data is HttpException || event.result.data is SocketException) {
          emit(await buildContentState(event: GallerySingleEventShowOffline()));
        } else {
          emit(GalleryStateError(event.result.data.toString()));
        }
      }
    });

    on<ChanEventDataError>((event, emit) async {
      if (event.error is HttpException || event.error is SocketException) {
        emit(await buildContentState(event: GallerySingleEventShowOffline()));
      } else {
        emit(GalleryStateError(event.error.toString()));
      }
    });

    on<GalleryEventOnPostSelected>((event, emit) async {
      await _threadsRepository.updateThread(_threadDetailModel.thread.copyWith(selectedPostId: event.postId));
    });

    on<GalleryEventOnLinkClicked>((event, emit) async {
      int postId = ChanUtil.getPostIdFromUrl(event.url);
      if (postId > 0) {
        add(GalleryEventOnPostSelected(postId));
      }
    });

    on<GalleryEventOnReplyClicked>((event, emit) async {
      emit(await buildContentState(event: GallerySingleEventShowReply(event.postId, _threadId, _boardId)));
    });

    on<GalleryEventHidePost>((event, emit) async {
      PostItem post = _threadDetailModel.findPostById(event.postId)!.copyWith(isHidden: true);
      await _postsRepository.updatePost(post);

      if (_threadDetailModel.selectedPostIndex == event.postId) {
        int? newSelectedPostId = -1;
        for (int i = 0; i < _threadDetailModel.allPosts.length; i++) {
          int dilatation = (i ~/ 2) + 1;
          int orientation = i % 2;
          int diff = orientation == 0 ? -dilatation : dilatation;
          int newSelectedPostIndex = (_threadDetailModel.selectedPostIndex + diff) % _threadDetailModel.allPosts.length;
          PostItem newSelectedPost = _threadDetailModel.allPosts[newSelectedPostIndex];
          if (!newSelectedPost.isHidden) {
            newSelectedPostId = newSelectedPost.postId;
            break;
          }
        }
        await _threadsRepository.updateThread(_threadDetailModel.thread.copyWith(selectedPostId: newSelectedPostId));
      }
    });

    on<GalleryEventOnAddToCollectionClicked>((event, emit) async {
      List<ThreadItemVO> _customThreads = await (await _threadsRepository.getCustomThreads()).toThreadItemVOList(_mediaHelper);
      emit(await buildContentState(
          event: GallerySingleEventShowCollectionsDialog(
        _customThreads,
        _threadDetailModel.selectedPostId,
      )));
    });

    on<GalleryEventCreateNewCollection>((event, emit) async {
      await _threadsRepository.createCustomThread(event.name);
      List<ThreadItemVO> _customThreads = await (await _threadsRepository.getCustomThreads()).toThreadItemVOList(_mediaHelper);
      emit(await buildContentState(
          event: GallerySingleEventShowCollectionsDialog(
        _customThreads,
        _threadDetailModel.selectedPostId,
      )));
    });

    on<GalleryEventAddPostToCollection>((event, emit) async {
      List<ThreadItemVO> _customThreads = await (await _threadsRepository.getCustomThreads()).toThreadItemVOList(_mediaHelper);
      ThreadItemVO thread = _customThreads.where((element) => element.subtitle == event.customThreadName).firstOrNull!;
      PostItem post = _threadDetailModel.findPostById(event.postId)!;
      await _threadsRepository.addPostToCustomThread(post, thread.threadId);
      emit(await buildContentState(event: GallerySingleEventShowPostAddedToCollectionSuccess()));
    });
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }

  Future<GalleryStateContent> buildContentState({GallerySingleEvent? event}) async {
    late PostItem selectedPost;
    String? overlayMetadataText = null;

    bool showAsCarousel = !_showAsReply && _threadDetailModel.selectedPost?.hasMedia() == true;
    int initialCarouselIndex = _threadDetailModel.findPostsMediaIndex(_initialPostId);

    if (showAsCarousel) {
      selectedPost = _threadDetailModel.selectedPost!;

      String order = "${_threadDetailModel.selectedMediaIndex + 1}/${_threadDetailModel.visibleMediaPosts.length}";
      String fileName = "${_threadDetailModel.selectedPost!.filename}${_threadDetailModel.selectedPost!.extension}";
      overlayMetadataText = "$order - $fileName";
    } else {
      selectedPost = _threadDetailModel.findPostById(_initialPostId)!;
    }
    List<PostItem> repliesForSelectedPost = await _threadDetailModel.findVisibleRepliesForPost(selectedPost.postId);
    List<MediaSource?> mediaSources = await Future.wait(_threadDetailModel.visibleMediaPosts.map((post) async {
      return _mediaHelper.getMediaSource(post);
    }));

    return GalleryStateContent(
      showAsCarousel: showAsCarousel,
      mediaSources: mediaSources.nonNulls.toList(),
      initialMediaIndex: initialCarouselIndex,
      overlayMetadataText: overlayMetadataText,
      replies: await [selectedPost, ...repliesForSelectedPost].toPostItemVOList(_mediaHelper),
      event: event,
    );
  }
}
