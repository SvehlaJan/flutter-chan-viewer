import 'package:flutter_chan_viewer/data/local/moor_db.dart';
import 'package:flutter_chan_viewer/models/local/posts_table.dart';
import 'package:flutter_chan_viewer/models/local/threads_table.dart';
import 'package:moor/moor.dart';

part 'threads_dao.g.dart';

@UseDao(tables: [ThreadsTable, PostsTable])
class ThreadsDao extends DatabaseAccessor<MoorDB> with _$ThreadsDaoMixin {
  ThreadsDao(MoorDB db) : super(db);

//  Stream<List<PostsTableData>> get allActiveThreadItemsStream => select(threadsTable).watch();

  Future<ThreadsTableData?> getThreadById(String boardId, int threadId) =>
      (select(threadsTable)..where((thread) => thread.boardId.equals(boardId) & thread.threadId.equals(threadId))).getSingleOrNull();

  Future<List<ThreadsTableData>> getThreadsByIds(String boardId, List<int> threadIds) =>
      (select(threadsTable)..where((thread) => thread.boardId.equals(boardId) & thread.threadId.isIn(threadIds))).get();

  Stream<ThreadsTableData> getThreadByStream(String boardId, int threadId) =>
      (select(threadsTable)..where((thread) => thread.boardId.equals(boardId) & thread.threadId.equals(threadId))).watchSingle();

  Future<List<ThreadsTableData>> getAllThreadItems() => select(threadsTable).get();

  Future<List<int>> getFavoriteThreadIds() => (select(threadsTable)..where((thread) => thread.isFavorite.equals(true))).map((thread) => thread.threadId).get();

  Future<List<ThreadsTableData>> getFavoriteThreads() => (select(threadsTable)
        ..where((thread) => thread.isFavorite.equals(true))
        ..orderBy([(thread) => OrderingTerm(expression: thread.timestamp, mode: OrderingMode.desc)]))
      .get();

  Future<List<ThreadsTableData>> getThreadsByBoardId(String? boardId) => (select(threadsTable)..where((thread) => thread.boardId.equals(boardId))).get();

  Future<List<ThreadsTableData>> getThreadsByBoardIdAndOnlineState(String? boardId, OnlineState onlineState) => (select(threadsTable)
        ..where((thread) => thread.boardId.equals(boardId) & thread.onlineState.equals(onlineState.index))
        ..orderBy([(thread) => OrderingTerm(expression: thread.lastModified, mode: OrderingMode.desc)]))
      .get();

  Future<List<ThreadsTableData>> getCustomThreads() => getThreadsByOnlineState(OnlineState.CUSTOM);

  Future<List<ThreadsTableData>> getArchivedThreads() => getThreadsByOnlineState(OnlineState.ARCHIVED);

  Future<List<ThreadsTableData>> getThreadsByOnlineState(OnlineState onlineState) =>
      (select(threadsTable)..where((thread) => thread.onlineState.equals(onlineState.index))).get();

  Future<void> insertThread(ThreadsTableData entry) {
    // return customInsert(
    //   "INSERT OR REPLACE INTO threads_table (timestamp, subtitle, content, filename, image_id, extension, board_id, thread_id, last_modified, selected_post_id, is_favorite, online_state, reply_count, image_count, unread_replies_count) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ON CONFLICT(board_id, thread_id) DO UPDATE SET selected_post_id = excluded.selected_post_id, is_favorite = excluded.is_favorite, unread_replies_count = excluded.unread_replies_count",
    //   updates: {threadsTable},
    //   variables: [
    //     Variable<int>(entry.timestamp),
    //     Variable<String>(entry.subtitle),
    //     Variable<String>(entry.content),
    //     Variable<String>(entry.filename),
    //     Variable<String>(entry.imageId),
    //     Variable<String>(entry.extension),
    //     Variable<String>(entry.boardId),
    //     Variable<int>(entry.threadId),
    //     Variable<int>(entry.lastModified),
    //     Variable<int>(entry.selectedPostId),
    //     Variable<bool>(entry.isFavorite),
    //     Variable<int>(entry.onlineState.index),
    //     Variable<int>(entry.replyCount),
    //     Variable<int>(entry.imageCount),
    //     Variable<int>(entry.unreadRepliesCount),
    //   ],
    // );
    return into(threadsTable).insert(
      entry,
      mode: InsertMode.insertOrReplace,
      onConflict: DoUpdate(
        (old) {
          return ThreadsTableCompanion.custom(
            isFavorite: old.isFavorite,
            selectedPostId: old.selectedPostId,
            unreadRepliesCount: old.unreadRepliesCount,
            replyCount: old.replyCount,
            imageCount: old.imageCount,
          );
        },
        target: [threadsTable.boardId, threadsTable.threadId],
      ),
    );
  }

  Future<void> insertThreadsList(List<ThreadsTableData> entries) async {
    return await batch((batch) => batch.insertAll(
          threadsTable,
          entries,
          mode: InsertMode.insertOrReplace,
          onConflict: DoUpdate(
            (dynamic old) {
              return ThreadsTableCompanion.custom(
                isFavorite: old.isFavorite,
                selectedPostId: old.selectedPostId,
                unreadRepliesCount: old.unreadRepliesCount,
                replyCount: old.replyCount,
                imageCount: old.imageCount,
              );
            },
            target: [threadsTable.boardId, threadsTable.threadId],
          ),
        ));
  }

  Future<bool> updateThread(ThreadsTableData entry) {
    return (update(threadsTable).replace(entry)).then((value) {
      print(value ? "Update goal row success" : "Update goal row failed");
      return value;
    });
  }

  Future<int> updateThreadsOnlineState(List<ThreadsTableData> threads, OnlineState onlineState) {
    List<int?> threadIds = threads.map((e) => e.threadId).toList();
    return (update(threadsTable)..where((t) => t.threadId.isIn(threadIds))).write(
      ThreadsTableCompanion(
        onlineState: Value(onlineState),
      ),
    );
  }

  Future<int> deleteThreadsWithOnlineStateOlderThan(OnlineState onlineState, int? timestamp) => (delete(threadsTable)
            ..where(
              (thread) => thread.onlineState.equals(onlineState.index) & thread.timestamp.isSmallerOrEqualValue(timestamp) & thread.isFavorite.equals(false),
            ))
          .go()
          .then((value) {
        print("Rows affected: $value");
        return value;
      });

  Future<int> deleteThreadsByIds(List<int?> threadIds) => (delete(threadsTable)..where((thread) => thread.threadId.isIn(threadIds))).go().then((value) {
        print("Rows affected: $value");
        return value;
      });

  Future<int> deleteThreadById(String? boardId, int? threadId) =>
      (delete(threadsTable)..where((thread) => thread.threadId.equals(threadId) & thread.boardId.equals(boardId))).go().then((value) {
        print("Rows affected: $value");
        return value;
      });

  Future<int> deleteOldThreads() {
    return (delete(threadsTable)
          ..where(
            (thread) =>
                thread.isFavorite.equals(false) &
                thread.onlineState.isIn([
                  OnlineState.NOT_FOUND.index,
                  OnlineState.UNKNOWN.index,
                ]),
          ))
        .go()
        .then((value) {
      print("Rows affected: $value");
      return value;
    });
  }
}
