import 'package:flutter_chan_viewer/data/local/moor_db.dart';
import 'package:flutter_chan_viewer/models/local/threads_table.dart';
import 'package:moor/moor.dart';

part 'threads_dao.g.dart';

@UseDao(tables: [ThreadsTable])
class ThreadsDao extends DatabaseAccessor<MoorDB> with _$ThreadsDaoMixin {
  ThreadsDao(MoorDB db) : super(db);

//  Stream<List<PostsTableData>> get allActiveThreadItemsStream => select(threadsTable).watch();

  Future<List<ThreadsTableData>> getAllThreadItems() => select(threadsTable).get();

  Future<List<ThreadsTableData>> getAllThreadsFromBoard(String boardId) => (select(threadsTable)..where((thread) => thread.boardId.equals(boardId))).get();

  Future<void> insertThreadsList(List<ThreadsTableData> entries) async {
    return await batch((batch) => batch.insertAll(threadsTable, entries, mode: InsertMode.insertOrReplace));
  }

  Future<bool> updateThread(ThreadsTableData entry) {
    return (update(threadsTable).replace(entry)).then((value) {
      print(value ? "Update goal row success" : "Update goal row failed");
      return value;
    });
  }

  Future<int> deleteThreadById(int threadId, String boardId) =>
      (delete(threadsTable)..where((thread) => thread.threadId.equals(threadId) & thread.boardId.equals(boardId))).go().then((value) {
        print("Row affecteds: $value");
        return value;
      });
}
