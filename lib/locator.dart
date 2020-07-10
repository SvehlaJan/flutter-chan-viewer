import 'package:flutter_chan_viewer/api/chan_api_provider.dart';
import 'package:flutter_chan_viewer/repositories/new_repository.dart';
import 'package:flutter_chan_viewer/utils/navigation_service.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/repositories/disk_cache.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton(() => NavigationService());
  getIt.registerLazySingleton<DiskCache>(() => DiskCache());
  getIt.registerLazySingleton<ChanApiProvider>(() => ChanApiProvider());
  getIt.registerSingletonAsync<Preferences>(() async => Preferences.initAndGet());
  getIt.registerLazySingletonAsync<ChanRepository>(() async => ChanRepository.initAndGet());
  getIt.registerLazySingletonAsync<NewChanRepository>(() async => NewChanRepository.initAndGet());
  getIt.registerLazySingletonAsync<ChanStorage>(() async => ChanStorage.initAndGet());
  getIt.registerLazySingletonAsync<ChanDownloader>(() async => ChanDownloader.initAndGet());
}