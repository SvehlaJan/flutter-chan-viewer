import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ChanCacheManager extends BaseCacheManager {
  static const key = 'libCachedImageData';

  static ChanCacheManager _instance;

  factory ChanCacheManager() {
    _instance ??= ChanCacheManager._();
    return _instance;
  }

  ChanCacheManager._() : super(key);

  @override
  Future<String> getFilePath() async {
    var directory = await getTemporaryDirectory();
    return p.join(directory.path, key);
  }

  // @override
  // Future<FileInfo> getFileFromCache(String url, {bool ignoreMemCache = false}) async {
  //   if (url.endsWith(".webm")) {
  //     FileInfo fileInfo = await super.getFileFromCache(url, ignoreMemCache: ignoreMemCache);
  //     if (fileInfo != null) {
  //       return fileInfo;
  //     }
  //
  //     CacheDirective cacheDirective = CacheDirective.fromPath(url);
  //     if (getIt<ChanStorage>().mediaFileExists(url, cacheDirective)) {
  //       Uint8List thumbnailData = await VideoThumbnail.thumbnailData(
  //         video: getIt<ChanStorage>().getFileAbsolutePath(url, cacheDirective),
  //         imageFormat: ImageFormat.JPEG,
  //         maxHeight: 512,
  //         quality: 75,
  //       );
  //       putFile(url, thumbnailData);
  //     } else {
  //       return null;
  //     }
  //   }
  //   return super.getFileFromCache(url, ignoreMemCache: ignoreMemCache);
  // }
}
