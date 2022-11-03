import 'package:drift/drift.dart';

abstract class ChanBaseTable extends Table {
  IntColumn get timestamp => integer().nullable()();

  TextColumn get subtitle => text().nullable()();

  TextColumn get content => text().nullable()();

  TextColumn get filename => text().nullable()();

  TextColumn get imageId => text().nullable()();

  TextColumn get extension => text().nullable()();
}
