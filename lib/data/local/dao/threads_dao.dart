import 'package:flutter_chan_viewer/data/local/moor_db.dart';
import 'package:flutter_chan_viewer/models/local/posts_table.dart';
import 'package:flutter_chan_viewer/models/local/threads_table.dart';
import 'package:moor/moor.dart';

part 'threads_dao.g.dart';

@UseDao(tables: [ThreadsTable, PostsTable])
class ThreadsDao extends DatabaseAccessor<MoorDB> with _$ThreadsDaoMixin {
  ThreadsDao(MoorDB db) : super(db);

//  Stream<List<PostsTableData>> get allActiveThreadItemsStream => select(threadsTable).watch();

  Future<ThreadsTableData> getThreadById(String boardId, int threadId) =>
      (select(threadsTable)..where((thread) => thread.boardId.equals(boardId) & thread.threadId.equals(threadId))).getSingle();

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

  Future<List<ThreadsTableData>> getThreadsByBoardId(String boardId) => (select(threadsTable)..where((thread) => thread.boardId.equals(boardId))).get();

  Future<List<ThreadsTableData>> getThreadsByBoardIdAndOnlineState(String boardId, OnlineState onlineState) => (select(threadsTable)
        ..where((thread) => thread.boardId.equals(boardId) & thread.onlineState.equals(onlineState.index))
        ..orderBy([(thread) => OrderingTerm(expression: thread.timestamp, mode: OrderingMode.desc)]))
      .get();

  Future<List<ThreadsTableData>> getCustomThreads() => getThreadsByOnlineState(OnlineState.CUSTOM);

  Future<List<ThreadsTableData>> getArchivedThreads() => getThreadsByOnlineState(OnlineState.ARCHIVED);

  Future<List<ThreadsTableData>> getThreadsByOnlineState(OnlineState onlineState) => (select(threadsTable)..where((thread) => thread.onlineState.equals(onlineState.index))).get();

  Future<void> insertThread(ThreadsTableData entry) {
    return into(threadsTable).insert(entry, onConflict: DoUpdate((old) => ThreadsTableCompanion.custom(isFavorite: old.isFavorite)));
  }

  Future<void> insertThreadsList(List<ThreadsTableData> entries) async {
    return await batch((batch) => batch.insertAll(threadsTable, entries, onConflict: DoUpdate((old) => ThreadsTableCompanion.custom(isFavorite: old.isFavorite))));
  }

  Future<bool> updateThread(ThreadsTableData entry) {
    return (update(threadsTable).replace(entry)).then((value) {
      print(value ? "Update goal row success" : "Update goal row failed");
      return value;
    });
  }

  Future<int> updateThreadsOnlineState(List<ThreadsTableData> threads, OnlineState onlineState) {
    List<int> threadIds = threads.map((e) => e.threadId).toList();
    return (update(threadsTable)..where((t) => t.threadId.isIn(threadIds))).write(
      ThreadsTableCompanion(
        onlineState: Value(onlineState),
      ),
    );
  }

  Future<int> deleteThreadsWithOnlineStateOlderThan(OnlineState onlineState, int timestamp) => (delete(threadsTable)
            ..where(
              (thread) => thread.onlineState.equals(onlineState.index) & thread.timestamp.isSmallerOrEqualValue(timestamp) & thread.isFavorite.equals(false),
            ))
          .go()
          .then((value) {
        print("Rows affected: $value");
        return value;
      });

  Future<int> deleteThreadsByIds(List<int> threadIds) => (delete(threadsTable)..where((thread) => thread.threadId.isIn(threadIds))).go().then((value) {
        print("Rows affected: $value");
        return value;
      });

  Future<int> deleteThreadById(int threadId, String boardId) =>
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
