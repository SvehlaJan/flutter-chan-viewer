import 'package:drift/drift.dart';
import 'package:flutter_chan_viewer/data/local/tables/chan_base_table.dart';

// // It needs to be here because of generated code can't import it
// enum OnlineStateDb { ONLINE, ARCHIVED, NOT_FOUND, CUSTOM, UNKNOWN }
//
// extension on OnlineStateDb {
//   OnlineStateDb fromOnlineState(OnlineState state) => OnlineStateDb.values[state.index];
// }

class ThreadsTable extends ChanBaseTable {
  @override
  Set<Column> get primaryKey => {threadId, boardId};

  TextColumn get boardId => text().customConstraint('REFERENCES boards_table(boardId) ON DELETE CASCADE')();

  IntColumn get threadId => integer()();

  IntColumn get lastModified => integer().nullable().withDefault(const Constant(0))();

  IntColumn get selectedPostId => integer().nullable().withDefault(const Constant(-1))();

  BoolColumn get isFavorite => boolean().nullable().withDefault(const Constant(false))();

  IntColumn get onlineState => integer().nullable().withDefault(const Constant(0))();

  IntColumn get replyCount => integer().nullable().withDefault(const Constant(-1))();

  IntColumn get imageCount => integer().nullable().withDefault(const Constant(-1))();

  IntColumn get lastSeenPostIndex => integer().nullable().withDefault(const Constant(-1))();
}
