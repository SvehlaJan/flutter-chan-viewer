import 'package:drift/drift.dart';
import 'package:flutter_chan_viewer/data/local/download_item.dart';
import 'package:flutter_chan_viewer/data/local/downloads_db.dart';
import 'package:flutter_chan_viewer/data/local/tables/downloads_table.dart';

part 'downloads_dao.g.dart';

@DriftAccessor(tables: [DownloadsTable])
class DownloadsDao extends DatabaseAccessor<DownloadsDB> with _$DownloadsDaoMixin {
  DownloadsDao(DownloadsDB db) : super(db);

  //  Stream<List<PostsTableData>> get allActiveDownloadItemsStream => select(downloadsTable).watch();

  Future<DownloadsTableData?> getDownloadById(String mediaId) {
    return (select(downloadsTable)..where((download) => download.mediaId.equals(mediaId))).getSingleOrNull();
  }

  Future<List<DownloadsTableData>> getDownloadByStatus(DownloadStatus status) {
    return (select(downloadsTable)..where((download) => download.status.equals(status.index))).get();
  }

  Future<DownloadsTableData?> getNextEnqueuedDownload() {
    return (select(downloadsTable)
          ..where((download) => download.status.isIn([DownloadStatus.ENQUEUED.index, DownloadStatus.RUNNING.index]))
          ..orderBy([(u) => OrderingTerm(expression: u.timestamp, mode: OrderingMode.asc)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<DownloadsTableData>> getDownloadItems() {
    return select(downloadsTable).get();
  }

  Future<void> insertDownload(DownloadsTableData entry) {
    return into(downloadsTable).insert(entry, mode: InsertMode.insertOrReplace);
  }

  Future<void> insertDownloadsList(List<DownloadsTableData> entries) async {
    return await batch((batch) => batch.insertAll(downloadsTable, entries, mode: InsertMode.insertOrReplace));
  }

  Future<bool> updateDownload(DownloadsTableData entry) {
    return (update(downloadsTable).replace(entry)).then((value) {
      return value;
    });
  }

  Future<int> deleteDownloadById(String mediaId) =>
      (delete(downloadsTable)..where((download) => download.mediaId.equals(mediaId))).go().then((value) {
        return value;
      });
}
