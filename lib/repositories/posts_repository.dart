import 'package:flutter_chan_viewer/data/local/local_data_source.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/utils/log_utils.dart';
import 'package:path_provider/path_provider.dart';

class PostsRepository with ChanLogger {
  final LocalDataSource _localDataSource;

  PostsRepository._(this._localDataSource);

  static Future<PostsRepository> create(LocalDataSource localDataSource) async {
    final repository = PostsRepository._(localDataSource);
    return repository;
  }

  Future<void> updatePost(PostItem post) async {
    await _localDataSource.updatePost(post);
  }
}