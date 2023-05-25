import 'package:drift/drift.dart';
import 'package:flutter_chan_viewer/data/local/tables/chan_base_table.dart';

class PostsTable extends ChanBaseTable {
  @override
  Set<Column> get primaryKey => {postId, threadId, boardId};

  TextColumn get boardId => text()();

  IntColumn get threadId => integer().customConstraint('REFERENCES threads_table(threadId) ON DELETE CASCADE')();

  IntColumn get postId => integer()();

  IntColumn get downloadProgress => integer().withDefault(const Constant(0))();

  BoolColumn get isHidden => boolean().nullable()();
}
