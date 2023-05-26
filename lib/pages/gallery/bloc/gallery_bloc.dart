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
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/repositories/chan_result.dart';
import 'package:flutter_chan_viewer/repositories/posts_repository.dart';
import 'package:flutter_chan_viewer/repositories/threads_repository.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/utils/exceptions.dart';
import 'package:flutter_chan_viewer/utils/log_utils.dart';
import 'package:flutter_chan_viewer/utils/media_helper.dart';

import 'gallery_event.dart';
import 'gallery_state.dart';

class GalleryBloc extends Bloc<ChanEvent, GalleryState> {
  final logger = LogUtils.getLogger();
  final ThreadsRepository _threadsRepository = getIt<ThreadsRepository>();
  final PostsRepository _postsRepository = getIt<PostsRepository>();

  final String _boardId;
  final int _threadId;
  final int _initialPostId;
  late ThreadDetailModel _threadDetailModel;
  List<ThreadItemVO>? _customThreads = null;
  late PostItem _selectedPost;

  bool _dataSuccessfullyFetched = false;

  CacheDirective get cacheDirective => CacheDirective(_boardId, _threadId);
  late final StreamSubscription _subscription;

  GalleryBloc(this._boardId, this._threadId, this._initialPostId) : super(GalleryStateLoading()) {
    _subscription = _threadsRepository.observeThreadDetail(_boardId, _threadId).listen((data) {
      add(ChanEventDataFetched(data));
    }, onError: (e) {
      add(ChanEventDataError(e));
    });

    on<ChanEventInitBloc>((event, emit) async {
      emit(GalleryStateLoading());
    });

    on<ChanEventDataFetched>((event, emit) {
      if (!_dataSuccessfullyFetched && event.result.data != null) {
        _selectedPost = event.result.data.findPostById(_initialPostId);
        _dataSuccessfullyFetched = true;
      }

      if (event.result is Loading) {
        if (event.result.data != null) {
          _threadDetailModel = event.result.data;
          emit(buildContentState());
        } else {
          emit(GalleryStateLoading());
        }
      } else if (event.result is Success) {
        _threadDetailModel = event.result.data;
        emit(buildContentState());
      } else if (event.result is Failure) {
        if (event.result.data is HttpException || event.result.data is SocketException) {
          emit(buildContentState(event: GallerySingleEventShowOffline()));
        } else {
          emit(GalleryStateError(event.result.data.toString()));
        }
      }
    });

    on<ChanEventDataError>((event, emit) {
      if (event.error is HttpException || event.error is SocketException) {
        emit(buildContentState(event: GallerySingleEventShowOffline()));
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
      emit(buildContentState(event: GallerySingleEventShowReply(event.postId, _threadId, _boardId)));
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

    on<GalleryEventCreateNewCollection>((event, emit) async {
      await _threadsRepository.createCustomThread(event.name);
      _customThreads = (await _threadsRepository.getCustomThreads()).map((e) => e.toThreadItemVO()).toList();
      emit(buildContentState(
          event: GallerySingleEventShowCollectionsDialog(
        _customThreads ?? [],
        _threadDetailModel.selectedPostId,
      )));
    });

    on<GalleryEventAddPostToCollection>((event, emit) async {
      if (_customThreads == null) {
        _customThreads = (await _threadsRepository.getCustomThreads()).map((e) => e.toThreadItemVO()).toList();
      }
      ThreadItemVO thread = _customThreads!.where((element) => element.subtitle == event.customThreadName).firstOrNull!;
      PostItem post = _threadDetailModel.findPostById(_selectedPost.postId)!;
      await _threadsRepository.addPostToCustomThread(post, thread.threadId);
      emit(buildContentState(event: GallerySingleEventShowPostAddedToCollectionSuccess()));
    });
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }

  GalleryStateContent buildContentState({GallerySingleEventNew? event}) {
    List<PostItemVO> replies =
        _threadDetailModel.selectedPost?.visibleReplies.map((e) => e.toPostItemVO()).toList() ?? [];
    return GalleryStateContent(
      mediaSources: _threadDetailModel.visibleMediaPosts.map((post) => post.getMediaSource()!).toList(),
      initialPostIndex: _threadDetailModel.findPostsMediaIndex(_initialPostId),
      selectedPostIndex: _threadDetailModel.selectedMediaIndex,
      selectedPost: _selectedPost.toPostItemVO(),
      replies: [_threadDetailModel.selectedPost!.toPostItemVO(), ...replies],
      event: event,
    );
  }
}
