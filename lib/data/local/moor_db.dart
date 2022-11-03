import 'dart:io';
import 'dart:isolate';

import 'package:drift/drift.dart';
import 'package:drift/isolate.dart';
import 'package:drift/native.dart';
import 'package:flutter_chan_viewer/data/local/dao/boards_dao.dart';
import 'package:flutter_chan_viewer/data/local/dao/posts_dao.dart';
import 'package:flutter_chan_viewer/data/local/dao/threads_dao.dart';
import 'package:flutter_chan_viewer/data/local/tables/boards_table.dart';
import 'package:flutter_chan_viewer/data/local/tables/posts_table.dart';
import 'package:flutter_chan_viewer/data/local/tables/threads_table.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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
class ChanDB extends _$ChanDB {
  ChanDB()
      : super(LazyDatabase(() async {
          final dbFolder = await getDatabasesPath();
          final file = File(p.join(dbFolder, 'db.sqlite'));
          return NativeDatabase(file, logStatements: true);
        }));

  ChanDB.connect(DatabaseConnection connection) : super.connect(connection);

  // FlutterQueryExecutor.inDatabaseFolder(
  //   path: "chan_viewer_db_${FlavorConfig.name.toLowerCase()}.sqlite",
  //   logStatements: true,
  // ),

  int get schemaVersion => 1;

  Future<void> purgeDatabase() async {
    await boardsDao.delete(boardsTable).go();
    await threadsDao.delete(threadsTable).go();
    await postsDao.delete(postsTable).go();
  }

  static Future<DriftIsolate> _createDriftIsolate() async {
    // this method is called from the main isolate. Since we can't use
    // getApplicationDocumentsDirectory on a background isolate, we calculate
    // the database path in the foreground isolate and then inform the
    // background isolate about the path.
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'db.sqlite');
    final receivePort = ReceivePort();

    await Isolate.spawn(
      _startBackground,
      _IsolateStartRequest(receivePort.sendPort, path),
    );

    // _startBackground will send the DriftIsolate to this ReceivePort
    return await receivePort.first as DriftIsolate;
  }

  static void _startBackground(_IsolateStartRequest request) {
    // this is the entry point from the background isolate! Let's create
    // the database from the path we received
    final executor = NativeDatabase(File(request.targetPath));
    // we're using DriftIsolate.inCurrent here as this method already runs on a
    // background isolate. If we used DriftIsolate.spawn, a third isolate would be
    // started which is not what we want!
    final driftIsolate = DriftIsolate.inCurrent(
      () => DatabaseConnection.fromExecutor(executor),
    );
    // inform the starting isolate about this, so that it can call .connect()
    request.sendDriftIsolate.send(driftIsolate);
  }

  static DatabaseConnection createDriftIsolateAndConnect() {
    return DatabaseConnection.delayed(() async {
      final isolate = await _createDriftIsolate();
      return await isolate.connect();
    }());
  }
}

// used to bundle the SendPort and the target path, since isolate entry point
// functions can only take one parameter.
class _IsolateStartRequest {
  final SendPort sendDriftIsolate;
  final String targetPath;

  _IsolateStartRequest(this.sendDriftIsolate, this.targetPath);
}
