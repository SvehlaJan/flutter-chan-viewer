import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ChanStorage {
  static final ChanStorage _instance = ChanStorage._internal();
  static bool _initialized = false;

  static const String PERMANENT_DIR = "saved";
  static const String CONTENT_FILENAME = "content.json";
  static const String SEPARATOR = "/";

  Directory _permanentDirectory;

  ChanStorage._internal() {
    // initialization code
  }

  static ChanStorage getSync() {
    if (!_initialized) throw Exception("Cache must be initialized at first!");
    return _instance;
  }

  static Future<ChanStorage> initAndGet() async {
    if (_initialized) return _instance;

    _instance._permanentDirectory = Directory(join((await getTemporaryDirectory()).path, PERMANENT_DIR));
    if (!_instance._permanentDirectory.existsSync()) await _instance._permanentDirectory.create();

    _initialized = true;
    return _instance;
  }

  bool mediaFileExists(String url, CacheDirective cacheDirective) => File(join(_permanentDirectory.path, _getFileRelativePath(url, cacheDirective))).existsSync();

  bool contentFileExists(CacheDirective cacheDirective) => File(join(_permanentDirectory.path, _getFolderRelativePath(cacheDirective), CONTENT_FILENAME)).existsSync();

  List<String> listDirectory(CacheDirective cacheDirective) => Directory(getFolderAbsolutePath(cacheDirective)).listSync(recursive: true).map((file) => file.path);

  String getFolderAbsolutePath(CacheDirective cacheDirective) => join(_permanentDirectory.path, _getFolderRelativePath(cacheDirective));

  String getFileAbsolutePath(String url, CacheDirective cacheDirective) => join(_permanentDirectory.path, _getFileRelativePath(url, cacheDirective));

  String _getFolderRelativePath(CacheDirective cacheDirective) => "${cacheDirective.boardId}$SEPARATOR${cacheDirective.threadId}";

  String _getFileRelativePath(String url, CacheDirective cacheDirective) => "${cacheDirective.boardId}$SEPARATOR${cacheDirective.threadId}$SEPARATOR${basename(url)}";

  File getMediaFile(String url, CacheDirective cacheDirective) {
    try {
      return File(getFileAbsolutePath(url, cacheDirective));
    } catch (e) {
      ChanLogger.e("File read error!", e);
    }
    return null;
  }

  Future<Uint8List> readMediaFile(String url, CacheDirective cacheDirective) async {
    try {
      File mediaFile = File(getFileAbsolutePath(url, cacheDirective));
      Uint8List data = await mediaFile.readAsBytes();
      return data;
    } catch (e) {
      ChanLogger.e("File read error!", e);
    }
    return null;
  }

  Future<File> writeMediaFile(String url, CacheDirective cacheDirective, Uint8List data) async {
    try {
      Directory directory = Directory(getFolderAbsolutePath(cacheDirective));
      if (!directory.existsSync()) await directory.create(recursive: true);

      File mediaFile = File(join(directory.path, basename(url)));
      File result = await mediaFile.writeAsBytes(data, flush: false);
      return result;
    } catch (e) {
      ChanLogger.e("File write error!", e);
    }
    return null;
  }

  Future<String> readContentString(CacheDirective cacheDirective) async {
    try {
      Directory directory = Directory(getFolderAbsolutePath(cacheDirective));
      File file = File(join(directory.path, CONTENT_FILENAME));
      String text = await file.readAsString();
      return text;
    } catch (e) {
      ChanLogger.e("File read error!", e);
      return null;
    }
  }

  Future<File> saveContentString(CacheDirective cacheDirective, String content) async {
    try {
      Directory directory = Directory(getFolderAbsolutePath(cacheDirective));
      if (!directory.existsSync()) await directory.create(recursive: true);

      File file = File(join(directory.path, CONTENT_FILENAME));
      File result = await file.writeAsString(content);
      return result;
    } catch (e) {
      ChanLogger.e("File write error!", e);
      return null;
    }
  }

  Future<void> deleteMediaFile(String url, CacheDirective cacheDirective) async {
    try {
      Directory directory = Directory(getFolderAbsolutePath(cacheDirective));
      if (!directory.existsSync()) return null;
      File file = File(join(directory.path, CONTENT_FILENAME));
      if (!file.existsSync()) return null;
      file.deleteSync(recursive: true);
      return null;
    } catch (e) {
      ChanLogger.e("File delete error!", e);
      return null;
    }
  }

  Future<void> deleteCacheFolder(CacheDirective cacheDirective) async {
    try {
      Directory directory = Directory(getFolderAbsolutePath(cacheDirective));
      if (!directory.existsSync()) return null;

      directory.deleteSync(recursive: true);
      return null;
    } catch (e) {
      ChanLogger.e("File delete error!", e);
      return null;
    }
  }

  Future<void> moveFolderToTempCache(CacheDirective cacheDirective) async {
    try {
      Directory directory = Directory(getFolderAbsolutePath(cacheDirective));
      if (!directory.existsSync()) return null;

      directory.deleteSync(recursive: true);
      return null;
    } catch (e) {
      ChanLogger.e("File delete error!", e);
      return null;
    }
  }

  Future<HashMap<String, List<String>>> listDirectories() async {
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
      ChanLogger.e("Error listing downloads!", e);
      return null;
    }
  }

  DownloadFolderInfo getThreadDownloadFolderInfo(CacheDirective cacheDirective) {
    Directory threadDirectory = Directory(getFolderAbsolutePath(cacheDirective));
    DownloadFolderInfo folderInfo = _getThreadFolderInfo(threadDirectory, cacheDirective.boardId);
    return folderInfo;
  }

  List<DownloadFolderInfo> getAllDownloadFoldersInfo() {
    try {
      List<DownloadFolderInfo> downloadedFolders = List<DownloadFolderInfo>();
      Directory boardsDirectory = Directory(_permanentDirectory.path);
      if (!boardsDirectory.existsSync()) boardsDirectory.createSync(recursive: true);

      for (FileSystemEntity boardFile in boardsDirectory.listSync()) {
        if (boardFile is Directory) {
          downloadedFolders.addAll(_getBoardFolderInfo(boardFile));
        }
      }

      return downloadedFolders;
    } catch (e) {
      ChanLogger.e("File read error!", e);
      return null;
    }
  }

  List<DownloadFolderInfo> _getBoardFolderInfo(Directory boardDirectory) {
    String boardName = basename(boardDirectory.path);
    List<DownloadFolderInfo> boardFolders = List();
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
    List<String> fileNames = List();
    threadDirectory.listSync().forEach((file) {
      fileNames.add(basename(file.path));
      filesSize += (file is File) ? file.lengthSync() : 0;
      filesCount += 1;
    });
    String threadName = basename(threadDirectory.path);
    CacheDirective cacheDirective = CacheDirective(boardId, int.parse(threadName));
    return DownloadFolderInfo(cacheDirective, filesCount, filesSize, fileNames);
  }

  void createDirectory(CacheDirective cacheDirective) {
    Directory directory = Directory(getFolderAbsolutePath(cacheDirective));
    if (!directory.existsSync()) directory.createSync(recursive: true);
  }
}

class DownloadFolderInfo {
  DownloadFolderInfo(this.cacheDirective, this.filesCount, this.filesSize, this.fileNames);

  final CacheDirective cacheDirective;
  final int filesCount;
  final int filesSize;
  final List<String> fileNames;
}
