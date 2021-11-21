import 'package:drift/drift.dart';
import 'package:flutter_chan_viewer/data/local/moor_db.dart';
import 'package:flutter_chan_viewer/models/local/boards_table.dart';

part 'boards_dao.g.dart';

@DriftAccessor(tables: [BoardsTable])
class BoardsDao extends DatabaseAccessor<ChanDB> with _$BoardsDaoMixin {
  BoardsDao(ChanDB db) : super(db);

//  Stream<List<PostsTableData>> get allActiveBoardItemsStream => select(boardsTable).watch();

  Future<BoardsTableData?> getBoardById(String boardId) {
    return (select(boardsTable)..where((board) => board.boardId.equals(boardId))).getSingleOrNull();
  }

  Future<List<BoardsTableData>> getBoardItems(bool includeNsfw) {
    if (includeNsfw) {
      return select(boardsTable).get();
    } else {
      return (select(boardsTable)..where((board) => board.workSafe.equals(true))).get();
    }
  }

  Future<void> insertBoardsList(List<BoardsTableData> entries) async {
    return await batch((batch) => batch.insertAll(boardsTable, entries, mode: InsertMode.insertOrReplace));
  }

  Future<bool> updateBoard(BoardsTableData entry) {
    return (update(boardsTable).replace(entry)).then((value) {
      print(value ? "Update goal row success" : "Update goal row failed");
      return value;
    });
  }

  Future<int> deleteBoardById(String boardId) =>
      (delete(boardsTable)..where((board) => board.boardId.equals(boardId))).go().then((value) {
        print("Row affecteds: $value");
        return value;
      });
}
