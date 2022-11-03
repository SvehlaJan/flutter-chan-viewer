import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';

abstract class ChanDownloader {
  Future<void> initializeAsync();

  Future<void> downloadThreadMedia(ThreadDetailModel model);

  Future<void> downloadPostMedia(PostItem post);

  Future<void> cancelAllDownloads();

  Future<void> cancelThreadDownload(ThreadDetailModel model);
}
