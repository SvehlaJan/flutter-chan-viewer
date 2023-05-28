import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chan_viewer/bloc/app_bloc/app_event.dart';
import 'package:flutter_chan_viewer/bloc/app_bloc/app_state.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/repositories/boards_repository.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/repositories/posts_repository.dart';
import 'package:flutter_chan_viewer/repositories/threads_repository.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/navigation_helper.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:json_theme/json_theme.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  late Preferences preferences;
  late ThemeData appTheme;
  LocalAuthentication auth = LocalAuthentication();
  AppLifecycleState lastLifecycleState = AppLifecycleState.inactive;
  AuthState authState = AuthState.auth_required;
  bool permissionsGranted = false;
  bool isMobile = Platform.isAndroid || Platform.isIOS;

  Future<void> initBloc() async {
    await getIt.getAsync<Preferences>();
    await getIt.getAsync<ChanDownloader>();
    await getIt.getAsync<ChanStorage>();
    await getIt.getAsync<ChanRepository>();
    await getIt.getAsync<BoardsRepository>();
    await getIt.getAsync<ThreadsRepository>();
    await getIt.getAsync<PostsRepository>();

    if (isMobile) {
      requestAuthentication();
      requestPermissions();
    }

    preferences = getIt.get<Preferences>();
  }

  Future<ThemeData> loadTheme() async {
    int appThemeIndex = preferences.getInt(Preferences.KEY_SETTINGS_THEME) ?? 0;
    if (appThemeIndex == AppTheme.light) {
      final themeStr = await rootBundle.loadString('assets/appainter_theme_light.json');
      final themeJson = jsonDecode(themeStr);
      return ThemeDecoder.decodeThemeData(themeJson)!;
    } else {
      final themeStr = await rootBundle.loadString('assets/appainter_theme_dark.json');
      final themeJson = jsonDecode(themeStr);
      return ThemeDecoder.decodeThemeData(themeJson)!;
    }
  }

  AppBloc() : super(AppStateLoading()) {
    on<AppEventAppStarted>((event, emit) async {
      await initBloc();
      appTheme = await loadTheme();
      if (!isMobile) {
        this.authState = AuthState.authenticated;
        emit(_buildContentState());
      }
    });
    on<AppEventSetTheme>((event, emit) async {
      preferences.setInt(Preferences.KEY_SETTINGS_THEME, event.appTheme.index);
      appTheme = await loadTheme();
      emit(_buildContentState());
    });
    on<AppEventAuthStateChange>((event, emit) {
      authState = event.authState;
      emit(_buildContentState());
    });
    on<AppEventPermissionRequestFinished>((event, emit) {
      this.permissionsGranted = event.granted;
      // emit(_buildContentState());
    });
    on<AppEventLifecycleChange>((event, emit) async {
      this.lastLifecycleState = event.lastLifecycleState;
      print("ChanViewerEventLifecycleChange: ${event.lastLifecycleState}");
      if (event.lastLifecycleState == AppLifecycleState.paused) {
        add(AppEventAuthStateChange(authState: AuthState.auth_required));
      } else if (event.lastLifecycleState == AppLifecycleState.resumed) {
        getIt<Preferences>().onAppResumed();
        if ([AuthState.auth_required, AuthState.forbidden].contains(this.authState)) {
          emit(_buildContentState());
          await requestAuthentication();
        }
      }
    });
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    print("AppBloc onError: $error");
    // emit(ChanStateError(error.toString()));
  }

  Future<void> requestAuthentication() async {
    bool authAvailable = await auth.canCheckBiometrics;
    bool deviceSupported = await auth.isDeviceSupported();
    if (!isMobile || !authAvailable || !deviceSupported) {
      print("Device does not support biometric auth");
      add(AppEventAuthStateChange(authState: AuthState.authenticated));
      return;
    }

    this.authState = AuthState.requesting;
    bool result = await auth.authenticate(
      localizedReason: 'Scan your fingerprint (or face or whatever) to authenticate',
      options: const AuthenticationOptions(
        useErrorDialogs: true,
        stickyAuth: true,
        biometricOnly: false,
      ),
    );
    add(AppEventAuthStateChange(authState: result ? AuthState.authenticated : AuthState.forbidden));
  }

  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();
    if (statuses.values.any((status) => (status.isGranted == false))) {
      add(AppEventPermissionRequestFinished(granted: false));
    } else {
      add(AppEventPermissionRequestFinished(granted: true));
    }
  }

  AppState _buildContentState({ThemeData? appTheme, AuthState? authState, AppSingleEvent? event}) {
    return AppStateContent(
      appTheme: appTheme ?? this.appTheme,
      authState: authState ?? this.authState,
      event: event,
    );
  }
}
