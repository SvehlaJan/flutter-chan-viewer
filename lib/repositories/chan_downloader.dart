import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';

abstract class ChanDownloader {
  Future<void> initializeAsync();

  Future<void> downloadThreadMedia(ThreadDetailModel model);

  Future<void> cancelAllDownloads();

  Future<void> cancelThreadDownload(ThreadDetailModel model);

  bool isMediaDownloaded(ChanPostBase post);
}
