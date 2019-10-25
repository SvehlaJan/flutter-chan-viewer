import 'dart:async';

import 'package:flutter_chan_viewer/api/chan_api_provider.dart';
import 'package:flutter_chan_viewer/models/api/boards_model.dart';
import 'package:flutter_chan_viewer/models/api/catalog_model.dart';
import 'package:flutter_chan_viewer/models/api/posts_model.dart';
import 'package:flutter_chan_viewer/models/api/threads_model.dart';

class ChanRepository {
  static final ChanRepository _repo = new ChanRepository._internal();
  final chanApiProvider = ChanApiProvider();

  static ChanRepository get() {
    return _repo;
  }

  ChanRepository._internal() {
    // initialization code
  }

  Future<BoardsModel> fetchAllBoards() => chanApiProvider.fetchBoardList();

  Future<CatalogThreadsModel> fetchCatalog(String boardId) => chanApiProvider.fetchCatalogThreadList(boardId);

  Future<ThreadsModel> fetchThreads(String boardId, int page) => chanApiProvider.fetchThreadList(boardId, page);

  Future<PostsModel> fetchPosts(String boardId, int threadId) => chanApiProvider.fetchPostList(boardId, threadId);
}
