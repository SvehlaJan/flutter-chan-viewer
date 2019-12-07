import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_chan_viewer/utils/network_image/cache_directive.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ChanCache {
  static final ChanCache _repo = new ChanCache._internal();
  static bool _initialized = false;

  static const String PERMANENT_DIR = "saved";
  static const String CONTENT_FILENAME = "content.json";
  static const String SEPARATOR = "/";

  Directory _permanentDirectory;

  ChanCache._internal() {
    // initialization code
  }

//  factory ChanCache() {
//    if (!_initialized) throw Exception("Cache must be initialized at first!");
//    return _repo;
//  }

  static ChanCache get() {
    if (!_initialized) throw Exception("Cache must be initialized at first!");
    return _repo;
  }

  static Future<void> init() async {
    if (_initialized) return;

    _repo._permanentDirectory = Directory(join((await getTemporaryDirectory()).path, PERMANENT_DIR));
    if (!_repo._permanentDirectory.existsSync()) await _repo._permanentDirectory.create();

    _initialized = true;
  }

  bool mediaFileExists(String url, CacheDirective cacheDirective) => File(join(_permanentDirectory.path, _getFileRelativePath(url, cacheDirective))).existsSync();

  bool contentFileExists(CacheDirective cacheDirective) => File(join(_permanentDirectory.path, _getFolderRelativePath(cacheDirective), CONTENT_FILENAME)).existsSync();

  List<String> listDirectory(CacheDirective cacheDirective) =>
      Directory(join(_permanentDirectory.path, _getFolderRelativePath(cacheDirective))).listSync(recursive: true).map((file) => file.path);

  String _getFolderRelativePath(CacheDirective cacheDirective) => "${cacheDirective.boardId}$SEPARATOR${cacheDirective.threadId}";

  String _getFileRelativePath(String url, CacheDirective cacheDirective) => "${cacheDirective.boardId}$SEPARATOR${cacheDirective.threadId}$SEPARATOR${_getFileName(url)}";

  String _getFileName(String url) => url.substring(url.lastIndexOf(SEPARATOR) + 1);

  String getFolderPath(CacheDirective cacheDirective) => join(_permanentDirectory.path, _getFolderRelativePath(cacheDirective));

  Future<Uint8List> getMediaFile(String url, CacheDirective cacheDirective) async {
    try {
      File mediaFile = File(join(_permanentDirectory.path, _getFileRelativePath(url, cacheDirective)));
      Uint8List data = await mediaFile.readAsBytes();
      return data;
    } catch (e) {
      print("File read error! ${e.toString()}");
    }
    return null;
  }

  Future<File> writeMediaFile(String url, CacheDirective cacheDirective, Uint8List data) async {
    try {
      Directory directory = Directory(join(_permanentDirectory.path, _getFolderRelativePath(cacheDirective)));
      if (!directory.existsSync()) await directory.create(recursive: true);

      File mediaFile = File(join(directory.path, _getFileName(url)));
//      print("Writing media { directory: ${directory.path}, mediaFile: ${mediaFile.path} }");
      File result = await mediaFile.writeAsBytes(data, flush: false);
      return result;
    } catch (e) {
      print("File write error! ${e.toString()}");
    }
    return null;
  }

  Future<String> readContentString(CacheDirective cacheDirective) async {
    try {
      Directory directory = Directory(join(_permanentDirectory.path, _getFolderRelativePath(cacheDirective)));
//      print("ChanCache: readContentString: { directory.path: ${directory.path}, directory.list: ${directory.listSync()}");
      File file = File(join(directory.path, CONTENT_FILENAME));
      String text = await file.readAsString();
      return text;
    } catch (e) {
      print("Couldn't read string from ${_getFolderRelativePath(cacheDirective)}");
      return null;
    }
  }

  Future<File> saveContentString(CacheDirective cacheDirective, String content) async {
    try {
      Directory directory = Directory(join(_permanentDirectory.path, _getFolderRelativePath(cacheDirective)));
      if (!directory.existsSync()) await directory.create(recursive: true);

      File file = File(join(directory.path, CONTENT_FILENAME));
      File result = await file.writeAsString(content);
      return result;
    } catch (e) {
      print("Couldn't write string to ${_getFolderRelativePath(cacheDirective)}");
      return null;
    }
  }

  Future<void> deleteMediaFile(String url, CacheDirective cacheDirective) async {
    try {
      Directory directory = Directory(join(_permanentDirectory.path, _getFolderRelativePath(cacheDirective)));
      if (!directory.existsSync()) return null;
      File file = File(join(directory.path, CONTENT_FILENAME));
      if (!file.existsSync()) return null;
      file.deleteSync(recursive: true);
      return null;
    } catch (e) {
      print("Couldn't delete media file { $e }");
      return null;
    }
  }

  Future<void> deleteCacheFolder(CacheDirective cacheDirective) async {
    try {
      Directory directory = Directory(join(_permanentDirectory.path, _getFolderRelativePath(cacheDirective)));
      if (!directory.existsSync()) return null;

      directory.deleteSync(recursive: true);
      return null;
    } catch (e) {
      print("Couldn't delete folder ${_getFolderRelativePath(cacheDirective)}");
      return null;
    }
  }

  Future<HashMap<String, List<String>>> listDirectories() async {
    try {
      Directory boardsDirectory = Directory(_permanentDirectory.path);
      if (!boardsDirectory.existsSync()) await boardsDirectory.create(recursive: true);

      HashMap<String, List<String>> threadMap = new HashMap();
      List<String> boards = boardsDirectory.listSync().map((file) => file.path.substring(file.path.lastIndexOf(SEPARATOR) + 1)).toList();
      for (String board in boards) {
        Directory threadDirectory = Directory(join(_permanentDirectory.path, board));
        List<String> threads = threadDirectory.listSync().map((file) => file.path.substring(file.path.lastIndexOf(SEPARATOR) + 1)).toList();
        threadMap[board] = threads;
      }

      return threadMap;
    } catch (e) {
      print("Couldn't list directories from ${_permanentDirectory.path}");
      return null;
    }
  }
}
