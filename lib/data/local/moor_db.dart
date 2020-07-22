import 'package:flutter_chan_viewer/data/local/dao/posts_dao.dart';
import 'package:flutter_chan_viewer/models/local/posts_table.dart';
import 'package:flutter_chan_viewer/utils/flavor_config.dart';
import 'package:moor/moor.dart';
import 'package:moor_flutter/moor_flutter.dart';

part 'moor_db.g.dart';

@UseMoor(tables: [PostsTable], daos: [PostsDao])
class MoorDB extends _$MoorDB {
  MoorDB() : super(FlutterQueryExecutor.inDatabaseFolder(path: "chan_viewer_db_${FlavorConfig.name.toLowerCase()}.sqlite", logStatements: true));
  int get schemaVersion => 1;
}

//LazyDatabase _init() {
//  return LazyDatabase(() async {
//    final dbFolder = await getApplicationDocumentsDirectory();
//    final file = File(p.join(dbFolder.path,
//        "chan_viewer_db_${FlavorConfig.name.toLowerCase()}.sqlite"));
//    return VmDatabase(file);
//  });
//}

//@UseMoor(tables: [PostsTable], daos: [ToDoDao])
//class MoorDB extends _$MoorDB {
////  MoorDB() : super(_init());
//
//  @override
//  int get schemaVersion => 1;
//
//  @override
//  MigrationStrategy get migration => MigrationStrategy(
//      onCreate: (m) {
//        return m.createAll();
//      },
//      onUpgrade: (m, from, to) async {});
//
//  Future<void> resetDb() async {
//    for (var table in allTables) {
//      await delete(table).go();
//    }
//  }
//}
