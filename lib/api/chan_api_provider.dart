import 'dart:async';
import 'dart:convert';

import 'package:flutter_chan_viewer/models/boards_model.dart';
import 'package:flutter_chan_viewer/models/thread_model.dart';
import 'package:flutter_chan_viewer/models/posts_model.dart';
import 'package:http/http.dart' show Client;

class ChanApiProvider {
  Client client = Client();
  static final _baseUrl = "https://a.4cdn.org";
  static final baseImageUrl = "https://i.4cdn.org";

  Future<BoardsModel> fetchBoardList() async {
    String url = "$_baseUrl/boards.json";
    print("Fetching board list: { url: $url }");

    final response = await client.get(url);
    print("Response status: ${response.statusCode}");
    if (response.statusCode == 200) {
      return BoardsModel.fromJson(json.decode(response.body));
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load boards');
    }
  }

  Future<ThreadsModel> fetchThreadList(String boardId) async {
    String url = "$_baseUrl/$boardId/catalog.json";
    print("Fetching thread list { url: $url }");

    final response = await client.get(url);
    print("Response status: ${response.statusCode}");
    if (response.statusCode == 200) {
      return ThreadsModel.fromJson(boardId, json.decode(response.body));
    } else {
      throw Exception('Failed to load threads');
    }
  }

  Future<PostsModel> fetchPostList(String boardId, int threadId) async {
    String url = "$_baseUrl/$boardId/thread/$threadId.json";
    print("Fetching post list { url: $url }");

    final response = await client.get(url);
    print("Response status: ${response.statusCode}");
    if (response.statusCode == 200) {
      return PostsModel.fromJson(boardId, threadId, json.decode(response.body));
    } else {
      throw Exception('Failed to load posts');
    }
  }
}
