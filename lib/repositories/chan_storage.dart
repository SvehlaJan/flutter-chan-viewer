import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_chan_viewer/models/helper/media_file_name.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/utils/log_utils.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ChanStorage with ChanLogger {
  static const String PERMANENT_DIR = "saved";
  static const String SEPARATOR = "/";

  late Directory _permanentDirectory;

  ChanStorage._();

  static Future<ChanStorage> create() async {
    ChanStorage storage = ChanStorage._();
    storage._permanentDirectory = Directory(join((await getApplicationSupportDirectory()).path, PERMANENT_DIR));
    if (!storage._permanentDirectory.existsSync()) await storage._permanentDirectory.create();

    var dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    return storage;
  }

  Future<bool> mediaFileExists(
    MediaFileName fileName,
    CacheDirective cacheDirective,
  ) async {
    final relativePath = _getFileRelativePath(fileName, cacheDirective);
    return await File(join(_permanentDirectory.path, relativePath)).exists();
  }

  Future<List<String>> listDirectory(CacheDirective cacheDirective) async {
    return (await Directory(getFolderAbsolutePath(cacheDirective)).list(recursive: true).map((file) => file.path))
        .toList();
  }

  String getFolderAbsolutePath(CacheDirective cacheDirective) {
    final relativePath = _getFolderRelativePath(cacheDirective);
    return join(_permanentDirectory.path, relativePath);
  }

  String getFileAbsolutePath(MediaFileName fileName, CacheDirective cacheDirective) {
    final relativePath = _getFileRelativePath(fileName, cacheDirective);
    return join(_permanentDirectory.path, relativePath);
  }

  String _getFolderRelativePath(CacheDirective cacheDirective) {
    return "${cacheDirective.boardId}$SEPARATOR${cacheDirective.threadId}";
  }

  String _getFileRelativePath(MediaFileName fileName, CacheDirective cacheDirective) {
    return "${cacheDirective.boardId}$SEPARATOR${cacheDirective.threadId}$SEPARATOR${fileName}";
  }

  File? getMediaFile(MediaFileName fileName, CacheDirective cacheDirective) {
    try {
      return File(getFileAbsolutePath(fileName, cacheDirective));
    } catch (e) {
      logError("File read error!", error: e);
    }
    return null;
  }

  Future<Uint8List?> readMediaData(MediaFileName fileName, CacheDirective cacheDirective) async {
    try {
      File mediaFile = File(getFileAbsolutePath(fileName, cacheDirective));
      Uint8List data = await mediaFile.readAsBytes();
      return data;
    } catch (e) {
//      logError("File read error!", e, stackTrace);
      return null;
    }
  }

  Future<File?> writeMediaFile(MediaFileName fileName, CacheDirective cacheDirective, Uint8List data) async {
    try {
      Directory directory = Directory(getFolderAbsolutePath(cacheDirective));
      if (!directory.existsSync()) await directory.create(recursive: true);

      File mediaFile = File(join(directory.path, fileName.toString()));
      File result = await mediaFile.writeAsBytes(data, flush: false);
      return result;
    } catch (e) {
      logError("File write error!", error: e);
      return null;
    }
  }

  Future<void> deleteMediaFile(String name, CacheDirective cacheDirective) async {
    try {
      Directory directory = Directory(getFolderAbsolutePath(cacheDirective));
      if (!directory.existsSync()) return null;
      File file = File(join(directory.path, name));
      if (!file.existsSync()) return null;
      file.deleteSync(recursive: true);
      return null;
    } catch (e) {
      logError("File delete error!", error: e);
      return null;
    }
  }

  Future<File?> copyMediaFile(
    MediaFileName fileName,
    CacheDirective sourceCacheDirective,
    CacheDirective targetCacheDirective,
  ) async {
    try {
      File sourceMediaFile = File(getFileAbsolutePath(fileName, sourceCacheDirective));
      Uint8List data = await sourceMediaFile.readAsBytes();

      Directory targetDirectory = Directory(getFolderAbsolutePath(targetCacheDirective));
      if (!targetDirectory.existsSync()) await targetDirectory.create(recursive: true);

      File targetMediaFile = File(join(targetDirectory.path, fileName.toString()));
      File result = await targetMediaFile.writeAsBytes(data, flush: false);
      return result;
    } catch (e) {
      logError("File copy error!", error: e);
      return null;
    }
  }

  Future<void> deleteMediaDirectory(CacheDirective cacheDirective) async {
    try {
      Directory directory = Directory(getFolderAbsolutePath(cacheDirective));
      if (!directory.existsSync()) return null;

      directory.deleteSync(recursive: true);
      return null;
    } catch (e) {
      logError("File delete error!", error: e);
      return null;
    }
  }

  Future<HashMap<String, List<String>>?> listDirectories() async {
    try {
      Directory boardsDirectory = Directory(_permanentDirectory.path);
      if (!boardsDirectory.existsSync()) await boardsDirectory.create(recursive: true);

      HashMap<String, List<String>> threadMap = HashMap();
      List<String> boards = boardsDirectory.listSync().map((file) => basename(file.path)).toList();
      for (String board in boards) {
        Directory threadDirectory = Directory(join(_permanentDirectory.path, board));
        List<String> threads = threadDirectory.listSync().map((file) => basename(file.path)).toList();
        threadMap[board] = threads;
      }

      return threadMap;
    } catch (e) {
      logError("Error listing downloads!", error: e);
      return null;
    }
  }

  DownloadFolderInfo getThreadDownloadFolderInfo(CacheDirective cacheDirective) {
    Directory threadDirectory = Directory(getFolderAbsolutePath(cacheDirective));
    DownloadFolderInfo folderInfo = _getThreadFolderInfo(threadDirectory, cacheDirective.boardId);
    return folderInfo;
  }

  List<DownloadFolderInfo>? getAllDownloadFoldersInfo() {
    try {
      List<DownloadFolderInfo> downloadedFolders = <DownloadFolderInfo>[];
      Directory boardsDirectory = Directory(_permanentDirectory.path);
      if (!boardsDirectory.existsSync()) boardsDirectory.createSync(recursive: true);

      for (FileSystemEntity boardFile in boardsDirectory.listSync()) {
        if (boardFile is Directory) {
          downloadedFolders.addAll(_getBoardFolderInfo(boardFile));
        }
      }

      return downloadedFolders;
    } catch (e) {
      logError("File read error!", error: e);
      return null;
    }
  }

  List<DownloadFolderInfo> _getBoardFolderInfo(Directory boardDirectory) {
    String boardName = basename(boardDirectory.path);
    List<DownloadFolderInfo> boardFolders = [];
    for (FileSystemEntity threadFile in boardDirectory.listSync()) {
      if (threadFile is Directory) {
        boardFolders.add(_getThreadFolderInfo(threadFile, boardName));
      }
    }
    return boardFolders;
  }

  DownloadFolderInfo _getThreadFolderInfo(Directory threadDirectory, String boardId) {
    int filesSize = 0;
    int filesCount = 0;
    List<String> fileNames = [];
    threadDirectory.listSync().forEach((file) {
      fileNames.add(basename(file.path));
      filesSize += (file is File) ? file.lengthSync() : 0;
      filesCount += 1;
    });
    String threadName = basename(threadDirectory.path);
    CacheDirective cacheDirective = CacheDirective(boardId, int.parse(threadName));
    return DownloadFolderInfo(cacheDirective, filesCount, filesSize, fileNames);
  }

  Future<void> createDirectory(CacheDirective cacheDirective) async {
    Directory directory = Directory(getFolderAbsolutePath(cacheDirective));
    if (!directory.existsSync()) await directory.create(recursive: true);
  }
}

class DownloadFolderInfo {
  DownloadFolderInfo(this.cacheDirective, this.filesCount, this.filesSize, this.fileNames);

  final CacheDirective cacheDirective;
  final int filesCount;
  final int filesSize;
  final List<String> fileNames;
}
