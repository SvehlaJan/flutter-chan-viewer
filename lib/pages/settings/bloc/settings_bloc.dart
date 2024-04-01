import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/data/local/local_data_source.dart';
import 'package:flutter_chan_viewer/data/local/moor_db.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/helper/moor_db_overview.dart';
import 'package:flutter_chan_viewer/models/ui/post_item.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/log_utils.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';

import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<ChanEvent, SettingsState> with ChanLogger {
  final ChanDownloader _downloader = getIt<ChanDownloader>();
  final ChanStorage _chanStorage = getIt<ChanStorage>();
  final LocalDataSource _localDataSource = getIt<LocalDataSource>();
  final Preferences _preferences = getIt<Preferences>();

  AppTheme? _appTheme;
  List<DownloadFolderInfo>? _downloads = <DownloadFolderInfo>[];
  MoorDbOverview _dbOverview = MoorDbOverview();

  SettingsBloc() : super(SettingsStateLoading()) {
    on<SettingsEventSetTheme>((event, emit) {
      _appTheme = event.theme;
      emit(_contentState);
    });

    on<ChanEventFetchData>((event, emit) async {
      int appThemeIndex = _preferences.getInt(Preferences.KEY_SETTINGS_THEME) ?? 0;
      _appTheme = AppTheme.values[appThemeIndex];
      _downloads = _chanStorage.getAllDownloadFoldersInfo();
      emit(_contentState);
    });

    on<SettingsEventExperiment>((event, emit) async {
      emit(SettingsStateLoading());

      // _dbOverview.boards.clear();
      // List<BoardItem> boards = await _localDataSource.getBoards(true);
      // for (BoardItem board in boards) {
      //   List<ThreadItem> threads = await _localDataSource.getThreadsByBoardId(board.boardId);
      //   if (threads.isEmpty) {
      //     continue;
      //   }
      //
      //   MoorBoardOverview boardsOverview = new MoorBoardOverview(
      //     board.boardId,
      //     threads.where((thread) => thread.onlineStatus == OnlineState.ONLINE.index).length,
      //     threads.where((thread) => thread.onlineStatus == OnlineState.ARCHIVED.index).length,
      //     threads.where((thread) => thread.onlineStatus == OnlineState.NOT_FOUND.index).length,
      //     threads.where((thread) => thread.onlineStatus == OnlineState.UNKNOWN.index).length,
      //   );
      //   _dbOverview.boards.add(boardsOverview);
      // }

      List<ThreadItem> favorites = await _localDataSource.getFavoriteThreads();
      for (ThreadItem thread in favorites) {
        List<PostItem> posts = await _localDataSource.getPostsFromThread(thread);
        for (PostItem post in posts) {
          if (post.hasMedia() && post.isMediaDownloaded) {
            logDebug("Post ${post.postId} is downloaded");
            // await _localDataSource.updatePost(post.copyWith(downloadProgress: ChanDownloadProgress.FINISHED.value));
          } else {
            logDebug("Post ${post.postId} is NOT downloaded");
            // await _localDataSource.updatePost(post.copyWith(downloadProgress: ChanDownloadProgress.NOT_STARTED.value));
          }
        }
      }

      emit(_contentState);
    });

    on<SettingsEventToggleShowNsfw>((event, emit) {
      emit(SettingsStateLoading());
      _preferences.setBool(Preferences.KEY_SETTINGS_SHOW_NSFW, event.enabled);
      emit(_contentState);
    });

    on<SettingsEventToggleBiometricLock>((event, emit) {
      emit(SettingsStateLoading());
      _preferences.setBool(Preferences.KEY_SETTINGS_BIOMETRIC_LOCK, event.enabled);
      emit(_contentState);
    });

    on<SettingsEventCancelDownloads>((event, emit) {
      emit(SettingsStateLoading());
      _downloader.cancelAllDownloads();
      emit(_contentState);
    });

    on<SettingsEventPurgeDatabase>((event, emit) async {
      emit(SettingsStateLoading());
      await getIt<ChanDB>()
        ..purgeDatabase();
      emit(_contentState);
    });

    on<SettingsEventDeleteFolder>((event, emit) async {
      emit(SettingsStateLoading());
      await _chanStorage.deleteMediaDirectory(event.cacheDirective);
      _downloads = _chanStorage.getAllDownloadFoldersInfo();
      emit(_contentState);
    });
  }

  SettingsStateContent get _contentState => SettingsStateContent(
        _appTheme,
        _downloads,
        _preferences.getBool(Preferences.KEY_SETTINGS_SHOW_NSFW, def: false),
        _preferences.getBool(Preferences.KEY_SETTINGS_BIOMETRIC_LOCK, def: false),
        _dbOverview,
      );
}
