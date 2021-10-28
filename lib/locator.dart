import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_chan_viewer/data/local/dao/boards_dao.dart';
import 'package:flutter_chan_viewer/data/local/dao/posts_dao.dart';
import 'package:flutter_chan_viewer/data/local/dao/threads_dao.dart';
import 'package:flutter_chan_viewer/data/local/local_data_source.dart';
import 'package:flutter_chan_viewer/data/local/moor_db.dart';
import 'package:flutter_chan_viewer/data/remote/remote_data_source.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/chan_cache_manager.dart';
import 'package:flutter_chan_viewer/utils/navigation_service.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<NavigationService>(() => NavigationService());
  getIt.registerLazySingleton<CacheManager>(
      () => ChanCacheManager.createCacheManager());
  getIt.registerLazySingleton<RemoteDataSource>(() => RemoteDataSource());
  getIt.registerLazySingleton<MoorDB>(() => MoorDB());
  getIt.registerLazySingleton<PostsDao>(() => PostsDao(getIt<MoorDB>()));
  getIt.registerLazySingleton<ThreadsDao>(() => ThreadsDao(getIt<MoorDB>()));
  getIt.registerLazySingleton<BoardsDao>(() => BoardsDao(getIt<MoorDB>()));
  getIt.registerLazySingleton<LocalDataSource>(() => LocalDataSource());
  getIt.registerSingletonAsync<Preferences>(
      () async => Preferences.initAndGet());
  getIt.registerLazySingletonAsync<ChanRepository>(
      () async => ChanRepository.initAndGet());
  getIt.registerLazySingletonAsync<ChanStorage>(
      () async => ChanStorage.initAndGet());
  getIt.registerLazySingletonAsync<ChanDownloader>(
      () async => ChanDownloader.initAndGet());
}
