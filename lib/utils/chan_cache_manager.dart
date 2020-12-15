import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:file/local.dart';
import 'package:file/file.dart';
import 'package:flutter_cache_manager/src/storage/file_system/file_system.dart' as c;

class ChanCacheManager {
  static const key = 'libCachedImageData';

  static CacheManager createCacheManager() {
    return CacheManager(Config(
      key,
      stalePeriod: const Duration(days: 1000),
      maxNrOfCacheObjects: 10000,
      repo: CacheObjectProvider(databaseName: key),
      fileSystem: IOFileSystem(key),
      fileService: HttpFileService(),
    ));
  }

  @override
  Future<String> getFilePath() async {
    var directory = await getTemporaryDirectory();
    return p.join(directory.path, key);
  }
}

class IOFileSystem implements c.FileSystem {
  final Future<Directory> _fileDir;

  IOFileSystem(String key) : _fileDir = createDirectory(key);

  static Future<Directory> createDirectory(String key) async {
    var baseDir = await getTemporaryDirectory();
    var path = p.join(baseDir.path, key);

    var fs = const LocalFileSystem();
    var directory = fs.directory((path));
    await directory.create(recursive: true);
    return directory;
  }

  @override
  Future<File> createFile(String name) async {
    assert(name != null);
    return (await _fileDir).childFile(name);
  }
}
