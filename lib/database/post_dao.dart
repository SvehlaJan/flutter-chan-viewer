import 'dart:async';
import 'package:flutter_chan_viewer/database/database_provider.dart';
import 'package:flutter_chan_viewer/models/posts_model.dart';


class ChanPostDao {
  final dbProvider = DatabaseProvider.dbProvider;

  //Adds new ChanPost records
  Future<int> createChanPost(ChanPost post) async {
    final db = await dbProvider.database;
    var result = db.insert(todoTABLE, post.toJson());
    return result;
  }

  //Get All ChanPost items
  //Searches if query string was passed
  Future<List<ChanPost>> getChanPosts({List<String> columns, String query}) async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>> result;
    if (query != null) {
      if (query.isNotEmpty)
        result = await db.query(todoTABLE,
            columns: columns,
            where: 'description LIKE ?',
            whereArgs: ["%$query%"]);
    } else {
      result = await db.query(todoTABLE, columns: columns);
    }

    List<ChanPost> posts = result.isNotEmpty
        ? result.map((item) => ChanPost.fromMappedJson("", item)).toList()
        : [];
    return posts;
  }

  //Update ChanPost record
  Future<int> updateChanPost(ChanPost post) async {
    final db = await dbProvider.database;

    var result = await db.update(todoTABLE, post.toJson(),
        where: "id = ?", whereArgs: [post.postId]);

    return result;
  }

  //Delete ChanPost records
  Future<int> deleteChanPost(int id) async {
    final db = await dbProvider.database;
    var result = await db.delete(todoTABLE, where: 'id = ?', whereArgs: [id]);

    return result;
  }

  //We are not going to use this in the demo
  Future deleteAllChanPosts() async {
    final db = await dbProvider.database;
    var result = await db.delete(
      todoTABLE,
    );

    return result;
  }
}