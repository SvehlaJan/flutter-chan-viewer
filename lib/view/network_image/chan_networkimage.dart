import 'dart:typed_data';
import 'dart:ui' as ui show Codec, hashValues;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/repositories/cache_directive.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';
import 'package:flutter_chan_viewer/view/network_image/networkimage_utils.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:flutter_chan_viewer/utils/extensions.dart';

typedef Future<Uint8List> ImageProcessing(Uint8List data);

/// Fetches the given URL from the network, associating it with some options.
class ChanNetworkImage extends ImageProvider<ChanNetworkImage> {
  ChanNetworkImage(
    this.url,
    this.fallbackUrl,
    this.cacheDirective, {
    this.header,
    this.retryLimit: 5,
    this.retryDuration: const Duration(milliseconds: 500),
    this.retryDurationFactor: 1.5,
    this.timeoutDuration: const Duration(seconds: 20),
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

  final String url;
  final String fallbackUrl;

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
        stream.setCompleter(load(key, PaintingBinding.instance.instantiateImageCodec));
      } else {
        final ImageStreamCompleter completer = PaintingBinding.instance.imageCache.putIfAbsent(key, () => load(key, PaintingBinding.instance.instantiateImageCodec));
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
  ImageStreamCompleter load(ChanNetworkImage key, DecoderCallback decode) {
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

    try {
      Uint8List imageData = await _loadData(key, cacheDirective);
      if (imageData != null) {
        if (key.postProcessing != null) imageData = (await key.postProcessing(imageData)) ?? imageData;
        if (key.loadedCallback != null) key.loadedCallback();
        return await PaintingBinding.instance.instantiateImageCodec(imageData);
      }
    } catch (e, stackTrace) {
      if (key.printError) ChanLogger.e("Error loading image from cache", e, stackTrace);
      _invalidateEntryInDiskCache(key, cacheDirective);
    }

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

  Future<Uint8List> _loadData(ChanNetworkImage key, CacheDirective cacheDirective) async {
    Uint8List cachedData = await _tryLoadFromCache(key.url, cacheDirective);
    if (cachedData != null) {
      return cachedData;
    } else if (key.fallbackUrl != null) {
      cachedData = await _tryLoadFromCache(key.fallbackUrl, cacheDirective);
      if (cachedData != null) {
        return cachedData;
      }
    }

    Uint8List remoteData = await loadFromRemote(
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

    if (remoteData != null) {
      if (key.preProcessing != null) remoteData = (await key.preProcessing(remoteData)) ?? remoteData;
      await getIt<ChanRepository>().saveMediaFile(key.url, cacheDirective, remoteData);
      return remoteData;
    }

    return null;
  }

  Future<Uint8List> _tryLoadFromCache(String url, CacheDirective cacheDirective) async {
    final Uint8List cachedData = await getIt<ChanRepository>().getCachedMediaFile(url, cacheDirective);
    if (cachedData != null) {
      if (url.endsWith(".webm")) {
        Uint8List thumbnailData = await VideoThumbnail.thumbnailData(
          video: getIt<ChanStorage>().getFileAbsolutePath(url, cacheDirective),
          imageFormat: ImageFormat.JPEG,
          maxHeight: 512,
          quality: 75,
        );
        return thumbnailData;
      } else {
        return cachedData;
      }
    }
    return null;
  }

  Future<void> _invalidateEntryInDiskCache(ChanNetworkImage key, CacheDirective cacheDirective) async {
    await getIt<ChanRepository>().deleteMediaFile(key.url, cacheDirective);
  }
}