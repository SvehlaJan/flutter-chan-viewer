import 'package:flutter_chan_viewer/models/local/chan_base_table.dart';
import 'package:moor/moor.dart';

class PostsTable extends ChanBaseTable {
  @override
  Set<Column> get primaryKey => {postId, threadId, boardId};

  TextColumn get boardId => text()();

  IntColumn get threadId => integer().customConstraint('REFERENCES threads_table(threadId) ON DELETE CASCADE')();

  IntColumn get postId => integer()();

  BoolColumn get isHidden => boolean()();
}
