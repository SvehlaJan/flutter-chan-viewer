import 'package:drift/drift.dart';

class DownloadsTable extends Table {
  @override
  Set<Column> get primaryKey => {mediaId};

  TextColumn get mediaId => text()();

  TextColumn get url => text()();

  TextColumn get path => text()();

  TextColumn get filename => text()();

  IntColumn get status => integer().withDefault(const Constant(0))();

  IntColumn get progress => integer().withDefault(const Constant(0))();

  IntColumn get timestamp => integer().withDefault(const Constant(0))();
}
