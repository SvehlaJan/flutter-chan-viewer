import 'package:drift/drift.dart';

class BoardsTable extends Table {
  @override
  Set<Column> get primaryKey => {boardId};

  TextColumn get boardId => text()();

  TextColumn? get title => text()();

  BoolColumn? get workSafe => boolean()();
}
