import 'dart:typed_data';
import 'dart:ui' as ui show Codec, hashValues;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chan_viewer/utils/chan_cache.dart';
import 'package:flutter_chan_viewer/utils/network_image/cache_directive.dart';
import 'package:flutter_chan_viewer/utils/network_image/disk_cache.dart';
import 'package:flutter_chan_viewer/utils/network_image/networkimage_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

typedef Future<Uint8List> ImageProcessing(Uint8List data);

/// Fetches the given URL from the network, associating it with some options.
class ChanNetworkImage extends ImageProvider<ChanNetworkImage> {
  ChanNetworkImage(
    this.url, {
    this.cacheDirective,
    this.header,
    this.retryLimit: 5,
    this.retryDuration: const Duration(milliseconds: 500),
    this.retryDurationFactor: 1.5,
    this.timeoutDuration: const Duration(seconds: 5),
    this.loadedCallback,
    this.loadFailedCallback,
    this.loadedFromDiskCacheCallback,
    this.fallbackAssetImage,
    this.fallbackImage,
    this.loadingProgress,
    this.getRealUrl,
    this.preProcessing,
    this.postProcessing,
    this.disableMemoryCache: false,
    this.printError = false,
  })  : assert(url != null),
        assert(retryLimit != null),
        assert(retryDuration != null),
        assert(retryDurationFactor != null),
        assert(timeoutDuration != null),
        assert(disableMemoryCache != null),
        assert(printError != null);

  /// The URL from which the image will be fetched.
  final String url;

  final CacheDirective cacheDirective;

  /// The HTTP headers that will be used with [http] to fetch image from network.
  final Map<String, String> header;

  /// The retry limit will be used to limit the retry attempts.
  final int retryLimit;

  /// The retry duration will give the interval between the retries.
  final Duration retryDuration;

  /// Apply factor to control retry duration between retry.
  final double retryDurationFactor;

  /// The timeout duration will give the timeout to a fetching function.
  final Duration timeoutDuration;

  /// The callback will fire when the image loaded.
  final VoidCallback loadedCallback;

  /// The callback will fire when the image failed to load.
  final VoidCallback loadFailedCallback;

  /// The callback will fire when the image loaded from DiskCache.
  VoidCallback loadedFromDiskCacheCallback;

  /// Displays image from an asset bundle when the image failed to load.
  final String fallbackAssetImage;

  /// The image will be displayed when the image failed to load
  /// and [fallbackAssetImage] is null.
  final Uint8List fallbackImage;

  /// Report loading progress and data when fetching image.
  LoadingProgress loadingProgress;

  /// Extract the real url before fetching.
  final UrlResolver getRealUrl;

  /// Receive the data([Uint8List]) and do some manipulations before saving.
  final ImageProcessing preProcessing;

  /// Receive the data([Uint8List]) and do some manipulations after saving.
  final ImageProcessing postProcessing;

  /// If set to enable, the image will skip [ImageCache].
  ///
  /// It is not recommended to disable momery cache, because image provider
  /// will be called a lot of times. If you do not enable [useDiskCache],
  /// image provider will fetch a lot of times. So do not use this option
  /// in production.
  ///
  /// If you want to use the same url with different [fallbackImage],
  /// you should make different [==].
  /// For example, you can set different [retryLimit].
  /// If you enable [useDiskCache], you can set different [differentId]
  /// with the same `() => Future.value(sameUrl)` in [getRealUrl].
  final bool disableMemoryCache;

  /// Print error messages.
  final bool printError;

  ImageStream resolve(ImageConfiguration configuration) {
    assert(configuration != null);
    final ImageStream stream = ImageStream();
    obtainKey(configuration).then<void>((ChanNetworkImage key) {
      if (key.disableMemoryCache) {
        stream.setCompleter(load(key));
      } else {
        final ImageStreamCompleter completer = PaintingBinding.instance.imageCache.putIfAbsent(key, () => load(key));
        if (completer != null) stream.setCompleter(completer);
      }
    });
    return stream;
  }

  @override
  Future<ChanNetworkImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<ChanNetworkImage>(this);
  }

  @override
  ImageStreamCompleter load(ChanNetworkImage key) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key),
      scale: 1.0,
      informationCollector: () sync* {
        yield DiagnosticsProperty<ImageProvider>('Image provider', this);
        yield DiagnosticsProperty<ChanNetworkImage>('Image key', key);
      },
    );
  }

  Future<ui.Codec> _loadAsync(ChanNetworkImage key) async {
    assert(key == this);

    String uId = uid(key.url);

    try {
      Uint8List _diskCache = await _loadFromDiskCache(key, uId, cacheDirective);
      if (_diskCache != null) {
        if (key.postProcessing != null) _diskCache = (await key.postProcessing(_diskCache)) ?? _diskCache;
        if (key.loadedCallback != null) key.loadedCallback();
        return await PaintingBinding.instance.instantiateImageCodec(_diskCache);
      }
    } catch (e) {
      if (key.printError) debugPrint(e.toString());
    }

//    if (key.url.endsWith(".webm")) {
//      Uint8List thumbnailData = await VideoThumbnail.thumbnailData(
//        video: key.url,
//        imageFormat: ImageFormat.WEBP,
//        maxHeightOrWidth: 0,
//        quality: 75,
//      );
//
//      if (key.postProcessing != null) thumbnailData = (await key.postProcessing(thumbnailData)) ?? thumbnailData;
//      if (key.loadedCallback != null) key.loadedCallback();
//      return await PaintingBinding.instance.instantiateImageCodec(thumbnailData);
//    }

    if (key.loadFailedCallback != null) key.loadFailedCallback();
    if (key.fallbackAssetImage != null) {
      ByteData imageData = await rootBundle.load(key.fallbackAssetImage);
      return await PaintingBinding.instance.instantiateImageCodec(imageData.buffer.asUint8List());
    }
    if (key.fallbackImage != null) return await PaintingBinding.instance.instantiateImageCodec(key.fallbackImage);

    return Future.error(StateError('Failed to load $url.'));
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final ChanNetworkImage typedOther = other;
    return url == typedOther.url && retryLimit == typedOther.retryLimit && retryDurationFactor == typedOther.retryDurationFactor && retryDuration == typedOther.retryDuration;
  }

  @override
  int get hashCode => ui.hashValues(url, retryLimit, retryDuration, retryDurationFactor, timeoutDuration);

  @override
  String toString() => '$runtimeType('
      '"$url",'
      'header: $header,'
      'retryLimit: $retryLimit,'
      'retryDuration: $retryDuration,'
      'retryDurationFactor: $retryDurationFactor,'
      'timeoutDuration: $timeoutDuration'
      ')';
}

/// Load the disk cache
///
/// Check the following conditions: (no [CacheRule])
/// 1. Check if cache directory exist. If not exist, create it.
/// 2. Check if cached file(uid) exist. If yes, load the cache,
///   otherwise go to download step.
Future<Uint8List> _loadFromDiskCache(ChanNetworkImage key, String uId, CacheDirective cacheDirective) async {
  if (cacheDirective != null) {
    if (ChanCache.get().mediaFileExists(key.url, cacheDirective)) {
      print("Permanent cache media hit! { url: ${key.url} }");
      return await ChanCache.get().getMediaFile(key.url, cacheDirective);
    }
  } else {
    Uint8List data = await DiskCache().load(uId);
    if (data != null) {
      print("Temporary cache media hit! { url: ${key.url} }");
      return data;
    }
  }

  Uint8List imageData = await loadFromRemote(
    key.url,
    key.header,
    key.retryLimit,
    key.retryDuration,
    key.retryDurationFactor,
    key.timeoutDuration,
    key.loadingProgress,
    key.getRealUrl,
    printError: key.printError,
  );
  if (imageData != null) {
    if (key.preProcessing != null) imageData = (await key.preProcessing(imageData)) ?? imageData;
    if (cacheDirective != null) {
      await ChanCache.get().writeMediaFile(key.url, cacheDirective, imageData);
    } else {
      await DiskCache().save(uId, imageData);
    }
    return imageData;
  }

  return null;
}
