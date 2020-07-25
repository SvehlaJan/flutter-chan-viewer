import 'package:flutter_chan_viewer/data/local/dao/boards_dao.dart';
import 'package:flutter_chan_viewer/data/local/dao/posts_dao.dart';
import 'package:flutter_chan_viewer/data/local/dao/threads_dao.dart';
import 'package:flutter_chan_viewer/data/local/moor_db.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/local/threads_table.dart';
import 'package:flutter_chan_viewer/models/ui/board_item.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';

class LocalDataSource {
  PostsDao _postsDao = getIt<PostsDao>();
  ThreadsDao _threadsDao = getIt<ThreadsDao>();
  BoardsDao _boardsDao = getIt<BoardsDao>();

  Future<void> savePosts(List<PostItem> posts) async {
    return _postsDao.insertPostsList(posts.map((post) => post.toTableData()).toList());
  }

  Future<List<PostItem>> getPostsByThread(ThreadItem thread) async {
    List<PostsTableData> posts = await _postsDao.getAllPostsFromThread(thread.threadId, thread.boardId);
    return posts.map((postData) => PostItem.fromTableData(postData, thread)).toList();
  }

  Future<void> saveThreads(List<ThreadItem> threads) async {
    return _threadsDao.insertThreadsList(threads.map((thread) => thread.toTableData()).toList());
  }

  Future<List<ThreadItem>> getThreadsByBoardIdAndOnlineState(String boardId, OnlineState onlineState) async {
    List<ThreadsTableData> threads = await _threadsDao.getAllThreadsByBoardIdAndOnlineState(boardId, onlineState);
    return threads.map((threadData) => ThreadItem.fromTableData(threadData)).toList();
  }

  Future<void> updateOnlineStateOfThreads(List<ThreadItem> onlineThreads) async {
    List<int> onlineThreadIds = onlineThreads.map((thread) => thread.threadId).toList();
    List<ThreadsTableData> localThreads = await _threadsDao.getThreadsByOnlineState(OnlineState.ONLINE);
    List<ThreadsTableData> notFoundThreads = localThreads.where((thread) => !onlineThreadIds.contains(thread.threadId)).toList();
    await _threadsDao.updateThreadsOnlineState(notFoundThreads, OnlineState.UNKNOWN);
    return null;
  }

  Future<BoardItem> getBoardById(String boardId) async {
    BoardsTableData boardsTableData = await _boardsDao.getBoardById(boardId);
    return boardsTableData != null ? BoardItem.fromTableData(boardsTableData) : null;
  }

  Future<List<BoardItem>> getBoards(bool includeNsfw) async {
    List<BoardsTableData> boards = await _boardsDao.getBoardItems(includeNsfw);
    return boards.map((boardData) => BoardItem.fromTableData(boardData)).toList();
  }

  Future<void> saveBoards(List<BoardItem> boards) async {
    return _boardsDao.insertBoardsList(boards.map((post) => post.toTableData()).toList());
  }
}
