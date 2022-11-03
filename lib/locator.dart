import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_chan_viewer/data/local/dao/boards_dao.dart';
import 'package:flutter_chan_viewer/data/local/dao/downloads_dao.dart';
import 'package:flutter_chan_viewer/data/local/dao/posts_dao.dart';
import 'package:flutter_chan_viewer/data/local/dao/threads_dao.dart';
import 'package:flutter_chan_viewer/data/local/downloads_db.dart';
import 'package:flutter_chan_viewer/data/local/local_data_source.dart';
import 'package:flutter_chan_viewer/data/local/moor_db.dart';
import 'package:flutter_chan_viewer/data/remote/remote_data_source.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader_impl.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader_mock.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/chan_cache_manager.dart';
import 'package:flutter_chan_viewer/utils/navigation_service.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

void setupLocator() {
  bool isMobile = Platform.isAndroid || Platform.isIOS;

  getIt.registerLazySingleton<NavigationService>(() => NavigationService());
  getIt.registerLazySingleton<CacheManager>(() => ChanCacheManager.createCacheManager());
  getIt.registerLazySingleton<RemoteDataSource>(() => RemoteDataSource());
  getIt.registerLazySingleton<ChanDB>(() => ChanDB.connect(ChanDB.createDriftIsolateAndConnect()));
  getIt.registerLazySingleton<DownloadsDB>(() => DownloadsDB.connect(DownloadsDB.createDriftIsolateAndConnect()));
  getIt.registerLazySingleton<PostsDao>(() => PostsDao(getIt<ChanDB>()));
  getIt.registerLazySingleton<ThreadsDao>(() => ThreadsDao(getIt<ChanDB>()));
  getIt.registerLazySingleton<BoardsDao>(() => BoardsDao(getIt<ChanDB>()));
  getIt.registerLazySingleton<DownloadsDao>(() => DownloadsDao(getIt<DownloadsDB>()));
  getIt.registerLazySingleton<LocalDataSource>(() => LocalDataSource());

  getIt.registerSingletonAsync<Preferences>(() async {
    Preferences preferences = new Preferences();
    preferences.initializeAsync();
    return preferences;
  });

  getIt.registerLazySingletonAsync<ChanRepository>(() async {
    ChanRepository chanRepository = new ChanRepository();
    await chanRepository.initializeAsync();
    return chanRepository;
  });

  getIt.registerLazySingletonAsync<ChanStorage>(() async {
    ChanStorage chanStorage = new ChanStorage();
    await chanStorage.initializeAsync();
    return chanStorage;
  });

  getIt.registerLazySingletonAsync<ChanDownloader>(() async {
    if (isMobile) {
      ChanDownloader chanDownloader = new ChanDownloaderImpl();
      await chanDownloader.initializeAsync();
      return chanDownloader;
    } else {
      return new ChanDownloaderMock();
    }
  });
}
