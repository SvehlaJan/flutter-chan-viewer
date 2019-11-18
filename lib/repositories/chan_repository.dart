import 'dart:async';
import 'dart:collection';

import 'package:flutter_chan_viewer/api/chan_api_provider.dart';
import 'package:flutter_chan_viewer/models/board_list_model.dart';
import 'package:flutter_chan_viewer/models/board_detail_model.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/utils/chan_cache.dart';

class ChanRepository {
  static final ChanRepository _repo = new ChanRepository._internal();

  final ChanCache _cache;
  final ChanApiProvider chanApiProvider;

  static const int CACHE_MAX_SIZE = 10;

  final Map<int, ThreadDetailModel> threadDetailMemoryCache = HashMap();

  static ChanRepository get() {
    return _repo;
  }

  ChanRepository._internal()
      : _cache = ChanCache.get(),
        chanApiProvider = ChanApiProvider() {
    // initialization code
  }

  Future<BoardListModel> fetchBoardList() => chanApiProvider.fetchBoardList();

  Future<BoardDetailModel> fetchBoardDetail(String boardId) => chanApiProvider.fetchThreadList(boardId);

  Future<ThreadDetailModel> fetchThreadDetail(bool forceFetch, String boardId, int threadId) async {
    if (!forceFetch && threadDetailMemoryCache.containsKey(threadId)) {
      return Future.value(threadDetailMemoryCache[threadId]);
    }

    threadDetailMemoryCache[threadId] = await chanApiProvider.fetchPostList(boardId, threadId);
    return threadDetailMemoryCache[threadId];
  }

  Future<ThreadDetailModel> addThreadToCache(ThreadDetailModel model) async {
    _cache.saveContentString(model.thread.getCacheDirective(), model.toJson().toString());

    return Future.value(model);
  }
}
