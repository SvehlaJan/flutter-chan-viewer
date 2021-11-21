import 'package:drift/drift.dart';
import 'package:flutter_chan_viewer/data/local/moor_db.dart';
import 'package:flutter_chan_viewer/models/local/posts_table.dart';

part 'posts_dao.g.dart';

@DriftAccessor(tables: [PostsTable])
class PostsDao extends DatabaseAccessor<ChanDB> with _$PostsDaoMixin {
  PostsDao(ChanDB db) : super(db);

  Future<PostsTableData?> getPostById(int postId, int threadId, String boardId) => (select(postsTable)
        ..where((post) => post.postId.equals(postId) & post.threadId.equals(threadId) & post.boardId.equals(boardId)))
      .getSingleOrNull();

  Future<List<PostsTableData>> getAllPostsItems() => select(postsTable).get();

  Future<List<PostsTableData>> getAllPostsFromThread(String boardId, int threadId) =>
      (select(postsTable)..where((post) => post.threadId.equals(threadId) & post.boardId.equals(boardId))).get();

  Stream<List<PostsTableData>> getAllPostsFromThreadStream(String boardId, int threadId) =>
      (select(postsTable)..where((post) => post.threadId.equals(threadId) & post.boardId.equals(boardId))).watch();

  Future<int> insertPost(PostsTableData entry) => into(postsTable).insertOnConflictUpdate(entry);

  Future<void> insertPostsList(List<PostsTableData> entries) async => await batch(
        (batch) => batch.insertAll(postsTable, entries,
            onConflict: DoUpdate((dynamic old) => PostsTableCompanion.custom(isHidden: old.isHidden))),
      );

  Future<bool> updatePost(PostsTableData entry) {
    return (update(postsTable).replace(entry)).then((value) {
      print(value ? "Update goal row success" : "Update goal row failed");
      return value;
    });
  }

  Future<int> deletePostById(int postId, String boardId) =>
      (delete(postsTable)..where((post) => post.postId.equals(postId) & post.boardId.equals(boardId)))
          .go()
          .then((value) {
        print("Row affecteds: $value");
        return value;
      });
}
