import 'package:drift/drift.dart';
import 'package:flutter_chan_viewer/data/local/moor_db.dart';
import 'package:flutter_chan_viewer/data/local/tables/boards_table.dart';

part 'boards_dao.g.dart';

@DriftAccessor(tables: [BoardsTable])
class BoardsDao extends DatabaseAccessor<ChanDB> with _$BoardsDaoMixin {
  BoardsDao(ChanDB db) : super(db);

  Future<BoardsTableData?> getBoardById(String boardId) {
    return (select(boardsTable)..where((board) => board.boardId.equals(boardId))).getSingleOrNull();
  }

  Future<List<BoardsTableData>> getAllBoards(bool includeNsfw) {
    if (includeNsfw) {
      return select(boardsTable).get();
    } else {
      return (select(boardsTable)..where((board) => board.workSafe.equals(true))).get();
    }
  }

  Stream<List<BoardsTableData>> getAllBoardsStream(bool includeNsfw) {
    if (includeNsfw) {
      return select(boardsTable).watch();
    } else {
      return (select(boardsTable)..where((board) => board.workSafe.equals(true))).watch();
    }
  }

  Future<void> insertBoardsList(List<BoardsTableData> entries) async {
    return await batch((batch) => batch.insertAll(boardsTable, entries, mode: InsertMode.insertOrReplace));
  }
}
