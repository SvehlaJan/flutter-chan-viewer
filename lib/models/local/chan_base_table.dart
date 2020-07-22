import 'package:moor/moor.dart';

abstract class ChanBaseTable extends Table {
  TextColumn get boardId => text()();
  IntColumn get threadId => integer()();
  IntColumn get timestamp => integer()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get content => text().nullable()();
  TextColumn get filename => text().nullable()();
  TextColumn get imageId => text().nullable()();
  TextColumn get extension => text().nullable()();

  // helper field
  BoolColumn get isFavorite => boolean()();
}
