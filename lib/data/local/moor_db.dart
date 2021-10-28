import 'dart:io';

import 'package:flutter_chan_viewer/data/local/dao/boards_dao.dart';
import 'package:flutter_chan_viewer/data/local/dao/posts_dao.dart';
import 'package:flutter_chan_viewer/data/local/dao/threads_dao.dart';
import 'package:flutter_chan_viewer/models/local/boards_table.dart';
import 'package:flutter_chan_viewer/models/local/posts_table.dart';
import 'package:flutter_chan_viewer/models/local/threads_table.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

part 'moor_db.g.dart';

@DriftDatabase(tables: [
  PostsTable,
  ThreadsTable,
  BoardsTable,
], daos: [
  PostsDao,
  ThreadsDao,
  BoardsDao
]
    //   , queries: {
    // "insertSingleThread":
    //     "INSERT OR REPLACE INTO threads_table (timestamp, subtitle, content, filename, image_id, extension, board_id, thread_id, last_modified, selected_post_id, is_favorite, online_state, reply_count, image_count, unread_replies_count) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ON CONFLICT(board_id, thread_id) DO UPDATE SET selected_post_id = excluded.selected_post_id, is_favorite = excluded.is_favorite, unread_replies_count = excluded.unread_replies_count"
// }
    )
class MoorDB extends _$MoorDB {
  MoorDB()
      : super(LazyDatabase(() async {
          final dbFolder = await getDatabasesPath();
          final file = File(p.join(dbFolder, 'db.sqlite'));
          return NativeDatabase(file, logStatements: true);
        }));

  // FlutterQueryExecutor.inDatabaseFolder(
  //   path: "chan_viewer_db_${FlavorConfig.name.toLowerCase()}.sqlite",
  //   logStatements: true,
  // ),

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
