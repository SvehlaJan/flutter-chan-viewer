import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_chan_viewer/data/local/local_data_source.dart';
import 'package:flutter_chan_viewer/data/remote/remote_data_source.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/archive_list_model.dart';
import 'package:flutter_chan_viewer/models/board_detail_model.dart';
import 'package:flutter_chan_viewer/models/board_list_model.dart';
import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';
import 'package:flutter_chan_viewer/models/local/threads_table.dart';
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
import 'package:path_provider/path_provider.dart';
import 'package:stream_transform/stream_transform.dart';

class ChanRepository {
  static final ChanRepository _instance = ChanRepository._internal();
  static bool _initialized = false;
  static const int CACHE_MAX_SIZE = 10;

  late ChanStorage _chanStorage;
  late ChanDownloader _chanDownloader;
  late RemoteDataSource _chanApiProvider;
  late LocalDataSource _localDataSource;

  static Future<ChanRepository> initAndGet() async {
    if (_initialized) return _instance;

    _instance._chanStorage = await getIt.getAsync<ChanStorage>();
    _instance._chanDownloader = await getIt.getAsync<ChanDownloader>();
    _instance._chanApiProvider = getIt<RemoteDataSource>();
    _instance._localDataSource = getIt<LocalDataSource>();

    var dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);

    _initialized = true;
    return _instance;
  }

  ChanRepository._internal() {
    // initialization code
  }

  bool isMediaDownloaded(ChanPostBase postBase) => _chanStorage.mediaFileExists(postBase.getMediaUrl()!, postBase.getCacheDirective());

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

  Future<BoardDetailModel?> fetchRemoteBoardDetail(String? boardId) async {
    BoardDetailModel boardDetailModel = await _chanApiProvider.fetchThreadList(boardId);

    List<int?> newThreadIds = boardDetailModel.threads.map((thread) => thread.threadId).toList();
    await _localDataSource.syncWithNewOnlineThreads(boardId, newThreadIds);
    await _localDataSource.saveThreads(boardDetailModel.threads);

    BoardDetailModel? newModel = await fetchCachedBoardDetail(boardId);
    return newModel;
  }

  Future<BoardDetailModel?> fetchCachedBoardDetail(String? boardId) async {
    List<ThreadItem> threads = await _localDataSource.getThreadsByBoardIdAndOnlineState(boardId, OnlineState.ONLINE);
    return threads.isNotEmpty ? BoardDetailModel.withThreads(threads) : null;
  }

  Future<ArchiveListModel> fetchRemoteArchiveList(String? boardId) async {
    ArchiveListModel archiveList = await _chanApiProvider.fetchArchiveList(boardId);
    await _localDataSource.syncWithNewArchivedThreads(boardId, archiveList.threads);
    return archiveList;
  }

  Future<Map<int?, ThreadItem?>> getArchivedThreadsMap(String? boardId) async {
    List<ThreadItem> threads = await _localDataSource.getThreadsByBoardIdAndOnlineState(boardId, OnlineState.ARCHIVED);
    return Map.fromIterable(threads, key: (thread) => thread.threadId, value: (thread) => thread);
  }

  Stream<ThreadDetailModel> getThreadDetailStream(String boardId, int threadId) {
    return _localDataSource.getThreadByIdStream(boardId, threadId).combineLatest(
        _localDataSource.getPostsByThreadIdStream(boardId, threadId), (thread, dynamic posts) => ThreadDetailModel.fromThreadAndPosts(thread, posts));
  }

  FutureOr<ThreadDetailModel?> fetchRemoteThreadDetail(String boardId, int threadId, bool isArchived) async {
    ThreadDetailModel model = await _chanApiProvider.fetchThreadDetail(boardId, threadId, isArchived);

    await _localDataSource.saveThread(model.thread);
    await _localDataSource.savePosts(model.allPosts);

    ThreadDetailModel? updatedModel = await fetchCachedThreadDetail(boardId, threadId);
    return updatedModel;
  }

  Future<ThreadDetailModel?> fetchCachedThreadDetail(String boardId, int threadId) async {
    ThreadItem? thread = await _localDataSource.getThreadById(boardId, threadId);
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
      onlineStatus: OnlineState.CUSTOM,
    );

    await _localDataSource.saveThread(customThread);

    ThreadItem? newThread = await _localDataSource.getThreadById(customThread.boardId, customThread.threadId);
    return newThread;
  }

  Future<PostItem?> addPostToCustomThread(PostItem originalPost, ThreadItem newThread) async {
    PostItem newPost = originalPost.copyWith(
      postId: DatabaseHelper.nextPostId(),
      threadId: newThread.threadId,
      boardId: Constants.customBoardId,
    );

    await _localDataSource.addPostToThread(newPost, newThread);
    _chanStorage.copyMediaFile(newPost.getMediaUrl()!, originalPost.getCacheDirective(), newThread.getCacheDirective());

    return _localDataSource.getPostById(newPost.postId, newThread.threadId, newThread.boardId);
  }

  Future<void> deleteCustomThread(ThreadDetailModel model) async {
    await _chanStorage.deleteMediaDirectory(model.thread.getCacheDirective());
    await _localDataSource.deleteThread(model.thread.boardId, model.thread.threadId);
  }

  Future<void> updatePost(PostItem post) async {
    await _localDataSource.updatePost(post);
  }

  Future<void> addThreadToFavorites(ThreadDetailModel model) async {
    await _localDataSource.updateThread(model.thread.copyWith(isThreadFavorite: true));
    await moveMediaToPermanentCache(model);
    _chanDownloader.downloadAllMedia(model);
  }

  Future<void> removeThreadFromFavorites(ThreadDetailModel model) async {
    await _localDataSource.updateThread(model.thread.copyWith(isThreadFavorite: false));

    await moveMediaToTemporaryCache(model);
    await _chanStorage.deleteMediaDirectory(model.thread.getCacheDirective());
  }

  Future<void> updateThread(ThreadItem thread) async {
    await _localDataSource.updateThread(thread);
  }

  Future<void> downloadAllMedia(ThreadDetailModel model) async {
    _chanDownloader.downloadAllMedia(model);
  }

  Future<List<ThreadDetailModel>> getFavoriteThreads() async {
    List<ThreadItem> threads = await _localDataSource.getFavoriteThreads();
    List<ThreadDetailModel> models = threads.map((thread) => ThreadDetailModel.fromThreadAndPosts(thread, [])).toList();

    return models;
  }

  Future<List<ThreadItem>> getCustomThreads() async => await _localDataSource.getCustomThreads();

  Future<void> moveMediaToPermanentCache(ThreadDetailModel model) async {
    model.allMediaPosts.forEach((post) async {
      FileInfo? fileInfo = await getIt<CacheManager>().getFileFromCache(post.getMediaUrl()!);
      if (fileInfo != null) {
        Uint8List fileData = await fileInfo.file.readAsBytes();
        await _chanStorage.writeMediaFile(post.getMediaUrl()!, post.getCacheDirective(), fileData);
      }
    });
  }

  Future<void> moveMediaToTemporaryCache(ThreadDetailModel model) async {
    model.allMediaPosts.forEach((post) async {
      Uint8List? data = await _chanStorage.readMediaData(post.getMediaUrl()!, post.getCacheDirective());
      if (data != null) {
        getIt<CacheManager>().putFile(post.getMediaUrl()!, data);
      }
    });
  }
}
