import 'package:flutter_chan_viewer/models/local/chan_base_table.dart';
import 'package:moor/moor.dart';

class PostsTable extends ChanBaseTable {
  @override
  Set<Column> get primaryKey => {postId, threadId, boardId};

  IntColumn get postId => integer()();
}