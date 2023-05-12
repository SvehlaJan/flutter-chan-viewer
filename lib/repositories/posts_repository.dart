import 'package:flutter_chan_viewer/data/local/local_data_source.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/utils/log_utils.dart';
import 'package:path_provider/path_provider.dart';

class PostsRepository {
  final logger = LogUtils.getLogger();

  late LocalDataSource _localDataSource;

  Future<void> initializeAsync() async {
    _localDataSource = getIt<LocalDataSource>();

    var dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
  }

  Future<void> updatePost(PostItem post) async {
    await _localDataSource.updatePost(post);
  }
}