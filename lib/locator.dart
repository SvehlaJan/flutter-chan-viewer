import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_chan_viewer/data/local/dao/boards_dao.dart';
import 'package:flutter_chan_viewer/data/local/dao/downloads_dao.dart';
import 'package:flutter_chan_viewer/data/local/dao/posts_dao.dart';
import 'package:flutter_chan_viewer/data/local/dao/threads_dao.dart';
import 'package:flutter_chan_viewer/data/local/downloads_db.dart';
import 'package:flutter_chan_viewer/data/local/local_data_source.dart';
import 'package:flutter_chan_viewer/data/local/moor_db.dart';
import 'package:flutter_chan_viewer/data/remote/remote_data_source.dart';
import 'package:flutter_chan_viewer/repositories/boards_repository.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader_mock.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader_new.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/repositories/downloads_repository.dart';
import 'package:flutter_chan_viewer/repositories/posts_repository.dart';
import 'package:flutter_chan_viewer/repositories/threads_repository.dart';
import 'package:flutter_chan_viewer/repositories/thumbnail_helper.dart';
import 'package:flutter_chan_viewer/utils/chan_cache_manager.dart';
import 'package:flutter_chan_viewer/utils/media_helper.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

GetIt getIt = GetIt.instance;

void setupLocator() {
  bool isMobile = Platform.isAndroid || Platform.isIOS;

  final token = RootIsolateToken.instance!;

  getIt.registerLazySingleton<CacheManager>(() => ChanCacheManager.createCacheManager());
  getIt.registerLazySingleton<RemoteDataSource>(() => RemoteDataSource());
  getIt.registerLazySingleton<ChanDB>(() => ChanDB.connect(ChanDB.createDriftIsolateAndConnect()));
  getIt.registerLazySingleton<DownloadsDB>(() => DownloadsDB.connect(DownloadsDB.createDriftIsolateAndConnect(token)));
  getIt.registerLazySingleton<PostsDao>(() => PostsDao(getIt<ChanDB>()));
  getIt.registerLazySingleton<ThreadsDao>(() => ThreadsDao(getIt<ChanDB>()));
  getIt.registerLazySingleton<BoardsDao>(() => BoardsDao(getIt<ChanDB>()));
  getIt.registerLazySingleton<DownloadsDao>(() => DownloadsDao(getIt<DownloadsDB>()));
  getIt.registerLazySingleton<LocalDataSource>(() => LocalDataSource());

  getIt.registerSingletonAsync<Preferences>(() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Preferences preferences = await Preferences.create(sharedPreferences);
    return preferences;
  });

  getIt.registerSingletonAsync<BoardsRepository>(() async {
    RemoteDataSource remoteDataSource = getIt.get<RemoteDataSource>();
    LocalDataSource localDataSource = getIt.get<LocalDataSource>();
    BoardsRepository repository = await BoardsRepository.create(remoteDataSource, localDataSource);
    return repository;
  });

  getIt.registerSingletonAsync<ThreadsRepository>(() async {
    RemoteDataSource remoteDataSource = getIt.get<RemoteDataSource>();
    LocalDataSource localDataSource = getIt.get<LocalDataSource>();
    ChanStorage chanStorage = await getIt.getAsync<ChanStorage>();
    DownloadsRepository downloadsRepository = await getIt.getAsync<DownloadsRepository>();
    ThreadsRepository repository = await ThreadsRepository.create(
      remoteDataSource,
      localDataSource,
      chanStorage,
      downloadsRepository,
    );
    return repository;
  });

  getIt.registerSingletonAsync<PostsRepository>(() async {
    LocalDataSource localDataSource = getIt.get<LocalDataSource>();
    PostsRepository repository = await PostsRepository.create(localDataSource);
    return repository;
  });

  getIt.registerSingletonAsync<DownloadsRepository>(() async {
    DownloadsDao downloadsDao = getIt.get<DownloadsDao>();
    ChanDownloader chanDownloader = await getIt.getAsync<ChanDownloader>();
    ChanStorage chanStorage = await getIt.getAsync<ChanStorage>();
    DownloadsRepository repository = await DownloadsRepository.create(downloadsDao, chanDownloader, chanStorage);
    return repository;
  });

  getIt.registerSingletonAsync<ChanStorage>(() async {
    ChanStorage chanStorage = await ChanStorage.create();
    return chanStorage;
  });

  getIt.registerSingletonAsync<ChanDownloader>(() async {
    if (isMobile) {
      ChanStorage chanStorage = await getIt.getAsync<ChanStorage>();
      ChanDownloader chanDownloader = await ChanDownloaderNew.create(chanStorage);
      return chanDownloader;
    } else {
      return new ChanDownloaderMock();
    }
  });

  getIt.registerSingletonAsync<ThumbnailHelper>(() async {
    ChanStorage chanStorage = await getIt.getAsync<ChanStorage>();
    ThumbnailHelper thumbnailHelper = await ThumbnailHelper.create(chanStorage);
    return thumbnailHelper;
  });

  getIt.registerSingletonAsync<MediaHelper>(() async {
    ChanStorage chanStorage = await getIt.getAsync<ChanStorage>();
    ChanDownloader chanDownloader = await getIt.getAsync<ChanDownloader>();
    ThumbnailHelper thumbnailHelper = await getIt.getAsync<ThumbnailHelper>();
    MediaHelper mediaHelper = await MediaHelper.create(chanStorage, chanDownloader, thumbnailHelper);
    return mediaHelper;
  });
}
