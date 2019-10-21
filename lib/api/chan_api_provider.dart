import 'dart:async';
import 'package:flutter_chan_viewer/models/api/boards_model.dart';
import 'package:flutter_chan_viewer/models/api/posts_model.dart';
import 'package:flutter_chan_viewer/models/api/threads_model.dart';
import 'package:http/http.dart' show Client;
import 'dart:convert';

class ChanApiProvider {
  Client client = Client();
  static final _baseUrl = "https://a.4cdn.org";
  static final _baseImageUrl = "https://i.4cdn.org";

  Future<BoardsModel> fetchBoardList() async {
    print("Fetching board list");
    final response = await client.get("$_baseUrl/boards.json");
    print("Response status: ${response.statusCode}");
    if (response.statusCode == 200) {
      return BoardsModel.fromJson(json.decode(response.body));
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load boards');
    }
  }

  Future<ThreadsModel> fetchThreadList(String boardId, int page) async {
    print("Fetching thread list { boardId: $boardId, page: $page }");
    final response = await client.get("$_baseUrl/$boardId/$page.json");
    print("Response status: ${response.statusCode}");
    if (response.statusCode == 200) {
      return ThreadsModel.fromJson(boardId, json.decode(response.body));
    } else {
      throw Exception('Failed to load threads');
    }
  }

  Future<PostsModel> fetchPostList(String boardId, int threadId) async {
    print("Fetching post list { boardId: $boardId, threadId: $threadId }");
    final response = await client.get("$_baseUrl/$boardId/thread/$threadId.json");
    print("Response status: ${response.statusCode}");
    if (response.statusCode == 200) {
      return PostsModel.fromJson(boardId, json.decode(response.body));
    } else {
      throw Exception('Failed to load posts');
    }
  }

  static String getImageUrl(ChanPost post, [bool thumbnail = false]) {
    if (post != null && post.imageId != null && post.extension != null) {
      String imageId = thumbnail ? "${post.imageId}s" : post.imageId;
      String extension = thumbnail ? ".jpg" : post.extension;
      return "$_baseImageUrl/${post.boardId}/$imageId$extension";
    } else {
      return null;
    }
  }
}
