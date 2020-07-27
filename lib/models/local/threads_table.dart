import 'package:flutter_chan_viewer/models/local/chan_base_table.dart';
import 'package:moor/moor.dart';

// It needs to be here because of generated code can't import it
enum OnlineState { ONLINE, ARCHIVED, NOT_FOUND, UNKNOWN }

class ThreadsTable extends ChanBaseTable {
  @override
  Set<Column> get primaryKey => {threadId, boardId};

  TextColumn get boardId => text()();

  IntColumn get threadId => integer()();

  BoolColumn get isFavorite => boolean()();

  IntColumn get onlineState => intEnum<OnlineState>()();

  IntColumn get replyCount => integer().nullable()();

  IntColumn get imageCount => integer().nullable()();
}
