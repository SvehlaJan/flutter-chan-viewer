import 'package:flutter_chan_viewer/data/local/dao/posts_dao.dart';
import 'package:flutter_chan_viewer/data/local/moor_db.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/post_item.dart';

class LocalDataSource {
  PostsDao _postsDao = getIt<PostsDao>();

  Future<void> savePosts(List<PostItem> posts) async {
    return _postsDao.insertPostsList(posts.map((post) => post.toTableData()).toList());
  }

  Future<List<PostItem>> getPostsByThreadId(int threadId, String boardId) async {
    List<PostsTableData> posts = await _postsDao.getAllPostsFromThread(threadId, boardId);
    return posts.map((post) => PostItem.fromTableData(post)).toList();
  }
}
