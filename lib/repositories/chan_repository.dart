import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_chan_viewer/data/local/local_data_source.dart';
import 'package:flutter_chan_viewer/data/remote/remote_data_source.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/archive_list_model.dart';
import 'package:flutter_chan_viewer/models/board_detail_model.dart';
import 'package:flutter_chan_viewer/models/board_list_model.dart';
import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';
import 'package:flutter_chan_viewer/models/helper/online_state.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/models/ui/board_item.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/database_helper.dart';
import 'package:flutter_chan_viewer/utils/exceptions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ChanRepository {
  static const int CACHE_MAX_SIZE = 10;

  late ChanStorage _chanStorage;
  late ChanDownloader _chanDownloader;
  late RemoteDataSource _chanApiProvider;
  late LocalDataSource _localDataSource;

  Future<void> initializeAsync() async {
    _chanStorage = await getIt.getAsync<ChanStorage>();
    _chanDownloader = await getIt.getAsync<ChanDownloader>();
    _chanApiProvider = getIt<RemoteDataSource>();
    _localDataSource = getIt<LocalDataSource>();

    var dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
  }

  bool isMediaDownloaded(ChanPostBase postBase) {
    return _chanStorage.mediaFileExists(
        postBase.getMediaUrl()!, postBase.getCacheDirective());
  }

  Future<BoardListModel?> fetchRemoteBoardList(bool includeNsfw) async {
    BoardListModel model = await _chanApiProvider.fetchBoardList();
    await _localDataSource.saveBoards(model.boards);
    return fetchCachedBoardList(includeNsfw);
  }

  Future<BoardListModel?> fetchCachedBoardList(bool includeNsfw) async {
    try {
      List<BoardItem> boards = await _localDataSource.getBoards(includeNsfw);
      return boards.isNotEmpty ? BoardListModel(boards) : null;
    } catch (e, stackTrace) {
      ChanLogger.e("fetchCachedBoardList error", e, stackTrace);
    }

    return null;
  }

  Future<BoardDetailModel?> fetchRemoteBoardDetail(String boardId) async {
    BoardDetailModel boardDetailModel =
        await _chanApiProvider.fetchThreadList(boardId);

    List<ThreadItem> newThreads = boardDetailModel.threads;
    List<int?> newThreadIds =
        newThreads.map((thread) => thread.threadId).toList();
    await _localDataSource.syncWithNewOnlineThreads(boardId, newThreadIds);
    await _localDataSource.saveThreads(newThreads);

    BoardDetailModel? newModel = await fetchCachedBoardDetail(boardId);
    return newModel;
  }

  Future<BoardDetailModel?> fetchCachedBoardDetail(String boardId) async {
    List<ThreadItem> threads = await _localDataSource
        .getThreadsByBoardIdAndOnlineState(boardId, OnlineState.ONLINE);
    return threads.isNotEmpty ? BoardDetailModel.withThreads(threads) : null;
  }

  Future<ArchiveListModel> fetchRemoteArchiveList(String boardId) async {
    ArchiveListModel archiveList =
        await _chanApiProvider.fetchArchiveList(boardId);
    await _localDataSource.syncWithNewArchivedThreads(
        boardId, archiveList.threads);
    return archiveList;
  }

  Future<Map<int?, ThreadItem?>> getArchivedThreadsMap(String boardId) async {
    List<ThreadItem> threads = await _localDataSource
        .getThreadsByBoardIdAndOnlineState(boardId, OnlineState.ARCHIVED);
    return Map.fromIterable(threads,
        key: (thread) => thread.threadId, value: (thread) => thread);
  }

  Stream<ThreadDetailModel> getThreadDetailStream(
      String boardId, int threadId) {
    return _localDataSource
        .getThreadByIdStream(boardId, threadId)
        .combineLatest(
            _localDataSource.getPostsByThreadIdStream(boardId, threadId),
            (thread, dynamic posts) =>
                ThreadDetailModel.fromThreadAndPosts(thread, posts));
  }

  Future<ThreadDetailModel> fetchRemoteThreadDetail(
      String boardId, int threadId, bool isArchived) async {
    try {
      ThreadDetailModel model = await _chanApiProvider.fetchThreadDetail(
          boardId, threadId, isArchived);
      await _localDataSource.saveThread(model.thread);
      await _localDataSource.savePosts(model.allPosts);

      ThreadDetailModel? updatedModel =
          await fetchCachedThreadDetail(boardId, threadId);
      return updatedModel!;
    } catch (e) {
      if (e is HttpException && e.errorCode == 404) {
        await _localDataSource.updateThreadOnlineState(
            threadId, OnlineState.NOT_FOUND);
      }

      throw e;
    }
  }

  Future<ThreadDetailModel?> fetchCachedThreadDetail(
      String boardId, int threadId) async {
    ThreadItem? thread =
        await _localDataSource.getThreadById(boardId, threadId);
    if (thread != null) {
      List<PostItem> posts = await _localDataSource.getPostsFromThread(thread);
      return ThreadDetailModel.fromThreadAndPosts(thread, posts);
    }

    return null;
  }

  Future<ThreadItem?> createCustomThread(String name) async {
    ThreadItem customThread = ThreadItem(
      threadId: DatabaseHelper.nextThreadId(),
      boardId: Constants.customBoardId,
      timestamp: ChanUtil.getNowTimestamp(),
      subtitle: name,
      onlineStatus: OnlineState.CUSTOM.index,
      isThreadFavorite: true,
    );

    await _localDataSource.saveThread(customThread);

    ThreadItem? newThread = await _localDataSource.getThreadById(
        customThread.boardId, customThread.threadId);
    return newThread;
  }

  Future<PostItem?> addPostToCustomThread(
      PostItem originalPost, ThreadItem newThread) async {
    PostItem newPost = originalPost.copyWith(
      postId: DatabaseHelper.nextPostId(),
      threadId: newThread.threadId,
      boardId: Constants.customBoardId,
      thread: newThread,
    );

    await _localDataSource.addPostToThread(newPost, newThread);
    _chanStorage.copyMediaFile(newPost.getMediaUrl()!,
        originalPost.getCacheDirective(), newPost.getCacheDirective());

    return _localDataSource.getPostById(
        newPost.postId, newThread.threadId, newThread.boardId);
  }

  Future<void> deleteCustomThread(ThreadDetailModel model) async {
    await _chanStorage.deleteMediaDirectory(model.thread.getCacheDirective());
    await _localDataSource.deleteThread(
        model.thread.boardId, model.thread.threadId);
  }

  Future<void> updatePost(PostItem post) async {
    await _localDataSource.updatePost(post);
  }

  Future<ThreadItem?> addThreadToFavorites(ThreadDetailModel model) async {
    await _localDataSource
        .updateThread(model.thread.copyWith(isThreadFavorite: true));

    await moveMediaToPermanentCache(model);
    _chanDownloader.downloadThreadMedia(model);
    return _localDataSource.getThreadById(
        model.thread.boardId, model.thread.threadId);
  }

  Future<ThreadItem?> removeThreadFromFavorites(ThreadDetailModel model) async {
    await _chanDownloader.cancelThreadDownload(model);
    // await moveMediaToTemporaryCache(model);
    await _chanStorage.deleteMediaDirectory(model.thread.getCacheDirective());

    await _localDataSource
        .updateThread(model.thread.copyWith(isThreadFavorite: false));
    return _localDataSource.getThreadById(
        model.thread.boardId, model.thread.threadId);
  }

  Future<ThreadItem?> updateThread(ThreadItem thread) async {
    await _localDataSource.updateThread(thread);
    return _localDataSource.getThreadById(thread.boardId, thread.threadId);
  }

  Future<void> downloadAllMedia(ThreadDetailModel model) async {
    _chanDownloader.downloadThreadMedia(model);
  }

  Future<List<ThreadDetailModel>> getFavoriteThreads() async {
    List<ThreadItem> threads = await _localDataSource.getFavoriteThreads();
    List<ThreadDetailModel> models = threads
        .map((thread) => ThreadDetailModel.fromThreadAndPosts(thread, []))
        .toList();

    return models;
  }

  Future<List<ThreadItem>> getCustomThreads() async =>
      await _localDataSource.getCustomThreads();

  Future<void> moveMediaToPermanentCache(ThreadDetailModel model) async {
    model.allMediaPosts.forEach((post) async {
      FileInfo? fileInfo =
          await getIt<CacheManager>().getFileFromCache(post.getMediaUrl()!);
      if (fileInfo != null) {
        Uint8List fileData = await fileInfo.file.readAsBytes();
        await _chanStorage.writeMediaFile(
            post.getMediaUrl()!, post.getCacheDirective(), fileData);
        if (post.isWebm()) {
          ChanRepository.createVideoThumbnail(post);
        }
      }
    });
  }

  Future<void> moveMediaToTemporaryCache(ThreadDetailModel model) async {
    model.allMediaPosts.forEach((post) async {
      Uint8List? data = await _chanStorage.readMediaData(
          post.getMediaUrl()!, post.getCacheDirective());
      if (data != null) {
        getIt<CacheManager>().putFile(post.getMediaUrl()!, data);
      }
    });
  }

  static File? getVideoThumbnail(ChanPostBase post) {
    String thumbnailUrl =
        post.getMediaUrl2(type: ChanPostMediaType.VIDEO_THUMBNAIL);
    File? imageFile = getIt<ChanStorage>()
        .getMediaFile(thumbnailUrl, post.getCacheDirective());
    if (imageFile != null && imageFile.existsSync()) {
      return imageFile;
    }
    return null;
  }

  static Future<File?> createVideoThumbnail(ChanPostBase post) async {
    String videoUrl = post.getMediaUrl2();
    String thumbnailUrl =
        post.getMediaUrl2(type: ChanPostMediaType.VIDEO_THUMBNAIL);
    String videoPath = getIt<ChanStorage>()
        .getFileAbsolutePath(videoUrl, post.getCacheDirective());
    String thumbnailPath = getIt<ChanStorage>()
        .getFileAbsolutePath(thumbnailUrl, post.getCacheDirective());
    String? newFilePath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: thumbnailPath,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 512,
        quality: 80);
    if (newFilePath != null && File(newFilePath).existsSync()) {
      return File(newFilePath);
    }
    return null;
  }
}
