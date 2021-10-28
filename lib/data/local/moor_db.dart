import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift/isolate.dart';
import 'package:flutter_chan_viewer/data/local/dao/boards_dao.dart';
import 'package:flutter_chan_viewer/data/local/dao/posts_dao.dart';
import 'package:flutter_chan_viewer/data/local/dao/threads_dao.dart';
import 'package:flutter_chan_viewer/models/local/boards_table.dart';
import 'package:flutter_chan_viewer/models/local/posts_table.dart';
import 'package:flutter_chan_viewer/models/local/threads_table.dart';
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
])
class MoorDB extends _$MoorDB {
  MoorDB()
      : super(LazyDatabase(() async {
          final dbFolder = await getDatabasesPath();
          final file = File(p.join(dbFolder, 'db.sqlite'));
          return NativeDatabase(file, logStatements: true);
        }));

  MoorDB.connect(DatabaseConnection connection) : super.connect(connection);

  // FlutterQueryExecutor.inDatabaseFolder(
  //   path: "chan_viewer_db_${FlavorConfig.name.toLowerCase()}.sqlite",
  //   logStatements: true,
  // ),

  int get schemaVersion => 1;

  static Future<DatabaseConnection> connectAsync() async {
    DriftIsolate isolate = await DriftIsolate.spawn(_backgroundConnection);
    return isolate.connect();
  }
}

// This needs to be a top-level method because it's run on a background isolate
DatabaseConnection _backgroundConnection() {
  // Construct the database to use. This example uses a non-persistent in-memory database each
  // time. You can use your existing NativeDatabase with a file as well, or a `LazyDatabase` if you
  // need to construct it asynchronously.
  // When using a Flutter plugin like `path_provider` to determine the path, also see the
  // "Initialization on the main thread" section below!
  final database = NativeDatabase.memory();
  return DatabaseConnection.fromExecutor(database);
}