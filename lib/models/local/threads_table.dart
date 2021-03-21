import 'package:flutter_chan_viewer/models/local/chan_base_table.dart';
import 'package:moor/moor.dart';

// It needs to be here because of generated code can't import it
enum OnlineState { ONLINE, ARCHIVED, NOT_FOUND, CUSTOM, UNKNOWN }

class ThreadsTable extends ChanBaseTable {
  @override
  Set<Column> get primaryKey => {threadId, boardId};

  TextColumn get boardId => text().customConstraint('REFERENCES boards_table(boardId) ON DELETE CASCADE')();

  IntColumn get threadId => integer()();

  IntColumn get lastModified => integer().nullable().withDefault(const Constant(0))();

  IntColumn get selectedPostId => integer().nullable().withDefault(const Constant(-1))();

  BoolColumn get isFavorite => boolean().nullable()();

  IntColumn get onlineState => intEnum<OnlineState>().nullable()();

  IntColumn get replyCount => integer().nullable()();

  IntColumn get imageCount => integer().nullable()();

  IntColumn get unreadRepliesCount => integer().nullable().withDefault(const Constant(0))();
}
