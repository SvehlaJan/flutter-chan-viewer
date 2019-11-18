import 'dart:async';
import 'dart:convert';

import 'package:flutter_chan_viewer/models/board_list_model.dart';
import 'package:flutter_chan_viewer/models/board_detail_model.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:http/http.dart' show Client;

class ChanApiProvider {
  Client client = Client();
  static final _baseUrl = "https://a.4cdn.org";
  static final baseImageUrl = "https://i.4cdn.org";

  Future<BoardListModel> fetchBoardList() async {
    String url = "$_baseUrl/boards.json";
    print("Fetching board list: { url: $url }");

    final response = await client.get(url);
    print("Response status: ${response.statusCode}");
    if (response.statusCode == 200) {
      return BoardListModel.fromJson(json.decode(response.body));
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load boards');
    }
  }

  Future<BoardDetailModel> fetchThreadList(String boardId) async {
    String url = "$_baseUrl/$boardId/catalog.json";
    print("Fetching thread list { url: $url }");

    final response = await client.get(url);
    print("Response status: ${response.statusCode}");
    if (response.statusCode == 200) {
      return BoardDetailModel.fromJson(boardId, json.decode(response.body));
    } else {
      throw Exception('Failed to load threads');
    }
  }

  Future<ThreadDetailModel> fetchPostList(String boardId, int threadId) async {
    String url = "$_baseUrl/$boardId/thread/$threadId.json";
    print("Fetching post list { url: $url }");

    final response = await client.get(url);
    print("Response status: ${response.statusCode}");
    if (response.statusCode == 200) {
      return ThreadDetailModel.fromJson(boardId, threadId, json.decode(response.body));
    } else {
      throw Exception('Failed to load posts');
    }
  }
}
