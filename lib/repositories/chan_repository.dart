import 'dart:async';

import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/helper/chan_post_base.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader.dart';
import 'package:flutter_chan_viewer/utils/log_utils.dart';
import 'package:path_provider/path_provider.dart';

class ChanRepository {
  final logger = LogUtils.getLogger();

  late ChanDownloader _chanDownloader;

  Future<void> initializeAsync() async {
    _chanDownloader = await getIt.getAsync<ChanDownloader>();

    var dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
  }

  bool isMediaDownloaded(ChanPostBase postBase) {
    return _chanDownloader.isPostMediaDownloaded(postBase);
  }

  Future<void> downloadAllMedia(ThreadDetailModel model) async {
    _chanDownloader.downloadThreadMedia(model);
  }
}
