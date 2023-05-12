import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_chan_viewer/data/local/local_data_source.dart';
import 'package:flutter_chan_viewer/data/remote/remote_data_source.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/helper/online_state.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader.dart';
import 'package:flutter_chan_viewer/repositories/chan_result.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/chan_util.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/database_helper.dart';
import 'package:flutter_chan_viewer/utils/exceptions.dart';
import 'package:flutter_chan_viewer/utils/log_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stream_transform/stream_transform.dart';

class ThreadsRepository {
  final logger = LogUtils.getLogger();

  late RemoteDataSource _chanApiProvider;
  late LocalDataSource _localDataSource;
  late ChanStorage _chanStorage;
  late ChanDownloader _chanDownloader;

  Future<void> initializeAsync() async {
    _chanApiProvider = getIt<RemoteDataSource>();
    _localDataSource = getIt<LocalDataSource>();
    _chanStorage = await getIt.getAsync<ChanStorage>();
    _chanDownloader = await getIt.getAsync<ChanDownloader>();

    var dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
  }

  Future<ThreadDetailModel> fetchRemoteThreadDetail(String boardId, int threadId, bool isArchived) async {
    try {
      ThreadDetailModel model = await _chanApiProvider.fetchThreadDetail(boardId, threadId, isArchived);
      await _localDataSource.saveThread(model.thread);
      await _localDataSource.savePosts(model.allPosts);

      ThreadDetailModel? updatedModel = await fetchCachedThreadDetail(boardId, threadId);
      return updatedModel!;
    } catch (e) {
      if (e is HttpException && e.errorCode == 404) {
        await _localDataSource.updateThreadOnlineState(threadId, OnlineState.NOT_FOUND);
      }
      throw e;
    }
  }

  Future<ThreadDetailModel?> fetchCachedThreadDetail(String boardId, int threadId) async {
    ThreadItem? thread = await _localDataSource.getThreadById(boardId, threadId);
    if (thread != null) {
      List<PostItem> posts = await _localDataSource.getPostsFromThread(thread);
      return ThreadDetailModel.fromThreadAndPosts(thread, posts);
    }

    return null;
  }

  Stream<DataResult<ThreadDetailModel>> fetchAndObserveThreadDetail(String boardId, int threadId,
      [bool isArchived = false]) {
    StreamController<DataResult<ThreadDetailModel>> controller = StreamController.broadcast();
    _localDataSource.getThreadById(boardId, threadId).then((thread) async {
      _localDataSource.getPostsFromThread(thread!).then((posts) {
        controller.add(DataResult.loading(ThreadDetailModel.fromThreadAndPosts(thread, posts)));
        _chanApiProvider.fetchThreadDetail(boardId, threadId, isArchived).then((model) async {
          await _localDataSource.saveThread(model.thread);
          await _localDataSource.savePosts(model.allPosts);

          controller.addStream(_localDataSource.getThreadByIdStream(boardId, threadId).combineLatest(
              _localDataSource.getPostsByThreadIdStream(boardId, threadId),
              (thread, dynamic posts) => DataResult.success(ThreadDetailModel.fromThreadAndPosts(thread, posts))));
        });
      });
    }).catchError((e) {
      controller.add(DataResult.error(e));
    });

    return controller.stream;
  }

  Future<ThreadItem?> addThreadToFavorites(ThreadDetailModel model) async {
    await _localDataSource.updateThread(model.thread.copyWith(isThreadFavorite: true));

    await moveMediaToPermanentCache(model);
    _chanDownloader.downloadThreadMedia(model);
    return _localDataSource.getThreadById(model.thread.boardId, model.thread.threadId);
  }

  Future<ThreadItem?> removeThreadFromFavorites(ThreadDetailModel model) async {
    await _chanDownloader.cancelThreadDownload(model);
    // await moveMediaToTemporaryCache(model);
    await _chanStorage.deleteMediaDirectory(model.thread.getCacheDirective());

    await _localDataSource.updateThread(model.thread.copyWith(isThreadFavorite: false));
    return _localDataSource.getThreadById(model.thread.boardId, model.thread.threadId);
  }

  Future<ThreadItem?> updateThread(ThreadItem thread) async {
    await _localDataSource.updateThread(thread);
    return _localDataSource.getThreadById(thread.boardId, thread.threadId);
  }

  Future<List<ThreadItem>> getCustomThreads() async => await _localDataSource.getCustomThreads();

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

    ThreadItem? newThread = await _localDataSource.getThreadById(customThread.boardId, customThread.threadId);
    return newThread;
  }

  Future<void> addPostToCustomThread(PostItem originalPost, ThreadItem newThread) async {
    PostItem newPost = originalPost.copyWith(
      postId: DatabaseHelper.nextPostId(),
      threadId: newThread.threadId,
      boardId: Constants.customBoardId,
      thread: newThread,
    );

    await _localDataSource.addPostToThread(newPost, newThread);
    _chanStorage.copyMediaFile(newPost.getMediaUrl()!, originalPost.getCacheDirective(), newPost.getCacheDirective());

    return;
  }

  Future<void> deleteCustomThread(ThreadDetailModel model) async {
    await _chanStorage.deleteMediaDirectory(model.thread.getCacheDirective());
    await _localDataSource.deleteThread(model.thread.boardId, model.thread.threadId);
  }

  Future<List<ThreadDetailModel>> getFavoriteThreads() async {
    List<ThreadItem> threads = await _localDataSource.getFavoriteThreads();
    List<ThreadDetailModel> models = threads.map((thread) => ThreadDetailModel.fromThreadAndPosts(thread, [])).toList();

    return models;
  }

  ///////////////////////////////////////////////////////////////////////

  Future<void> moveMediaToPermanentCache(ThreadDetailModel model) async {
    model.allMediaPosts.forEach((post) async {
      FileInfo? fileInfo = await getIt<CacheManager>().getFileFromCache(post.getMediaUrl()!);
      if (fileInfo != null) {
        Uint8List fileData = await fileInfo.file.readAsBytes();
        await _chanStorage.writeMediaFile(post.getMediaUrl()!, post.getCacheDirective(), fileData);
      }
    });
  }
}
