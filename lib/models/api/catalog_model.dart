import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/api/chan_api_provider.dart';
import 'package:flutter_chan_viewer/models/api/threads_model.dart';

import 'posts_model.dart';

class CatalogThreadsModel extends Equatable {
  final List<ChanCatalogThread> _threads = [];

  CatalogThreadsModel.fromJson(String boardId, List<dynamic> parsedJson) {
    for (Map<String, dynamic> page in parsedJson) {
      for (Map<String, dynamic> thread in page['threads'] ?? []) {
        _threads.add(ChanCatalogThread(boardId, thread['no'], thread['now'], thread['com'], thread['filename'], thread['tim'].toString(), thread['ext']));
      }
    }
  }

  List<ChanCatalogThread> get threads => _threads;
}

class ChanCatalogThread extends Equatable {
  final String boardId;
  final int threadId;
  final String date;
  final String content;
  final String filename;
  final String imageId;
  final String extension;

  ChanCatalogThread(this.boardId, this.threadId, this.date, this.content, this.filename, this.imageId, this.extension)
      : super([
          boardId,
          threadId,
          date,
          content,
          filename,
          imageId,
          extension
        ]);

  String getThumbnailUrl() => ChanApiProvider.getImageUrl(this.boardId, this.imageId, this.extension, true);
}
