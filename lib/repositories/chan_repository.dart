import 'dart:async';
import 'dart:collection';

import 'package:flutter_chan_viewer/api/chan_api_provider.dart';
import 'package:flutter_chan_viewer/models/boards_model.dart';
import 'package:flutter_chan_viewer/models/thread_model.dart';
import 'package:flutter_chan_viewer/models/posts_model.dart';
import 'package:flutter_chan_viewer/utils/chan_cache.dart';

class ChanRepository {
  static final ChanRepository _repo = new ChanRepository._internal();

  final _cache;
  final chanApiProvider;

  static const int CACHE_MAX_SIZE = 10;

  final Map<int, ChanBoard> boardsCache = HashMap();
  final Map<int, ChanThread> threadsCache = HashMap();
  final Map<int, PostsModel> postsCache = HashMap();

  static ChanRepository get() {
    return _repo;
  }

  ChanRepository._internal() : _cache = ChanCache.get(), chanApiProvider = ChanApiProvider() {
    // initialization code
  }

  Future<BoardsModel> fetchBoards() => chanApiProvider.fetchBoardList();

  Future<ThreadsModel> fetchThreads(String boardId) {
    return chanApiProvider.fetchThreadList(boardId);
  }

  Future<PostsModel> fetchPosts(bool forceFetch, String boardId, int threadId) async {
    if (!forceFetch && postsCache.containsKey(threadId)) {
      return Future.value(postsCache[threadId]);
    }

    postsCache[threadId] = await chanApiProvider.fetchPostList(boardId, threadId);
    return postsCache[threadId];
  }
}
