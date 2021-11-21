import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/navigation_helper.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, ChanState> {
  AppBloc() : super(AppStateLoading());

  LocalAuthentication auth = LocalAuthentication();
  AppLifecycleState lastLifecycleState = AppLifecycleState.inactive;
  AuthState authState = AuthState.auth_required;
  AppTheme appTheme = AppTheme.undefined;
  bool permissionsGranted = false;
  bool isMobile = Platform.isAndroid || Platform.isIOS;

  Future<void> initBloc() async {
    await getIt.getAsync<Preferences>();
    await getIt.getAsync<ChanDownloader>();
    await getIt.getAsync<ChanStorage>();
    await getIt.getAsync<ChanRepository>();

    if (isMobile) {
      requestAuthentication();
      requestPermissions();
    }
  }

  @override
  Stream<ChanState> mapEventToState(AppEvent event) async* {
    try {
      if (event is AppEventAppStarted) {
        await initBloc();
        int appThemeIndex = (await getIt.getAsync<Preferences>()).getInt(Preferences.KEY_SETTINGS_THEME) ?? 0;
        appTheme = AppTheme.values[appThemeIndex];
        if (!isMobile) {
          this.authState = AuthState.authenticated;
          yield _buildContentState();
        }
      } else if (event is AppEventSetTheme) {
        appTheme = event.appTheme;
        yield _buildContentState();
      } else if (event is AppEventLifecycleChange && isMobile) {
        this.lastLifecycleState = event.lastLifecycleState;
        print("ChanViewerEventLifecycleChange: ${event.lastLifecycleState}");
        if (event.lastLifecycleState == AppLifecycleState.paused) {
          add(AppEventAuthStateChange(authState: AuthState.auth_required));
        } else if (event.lastLifecycleState == AppLifecycleState.resumed) {
          if ([AuthState.auth_required, AuthState.forbidden].contains(this.authState)) {
            yield _buildContentState();
            await requestAuthentication();
          }
        }
      } else if (event is AppEventAuthStateChange) {
        this.authState = event.authState;
        yield _buildContentState();
      } else if (event is AppEventPermissionRequestFinished) {
        this.permissionsGranted = event.granted;
        // yield _buildContentState();
      }
    } catch (e, stackTrace) {
      ChanLogger.e("Event error!", e, stackTrace);
      yield ChanStateError(e.toString());
    }
  }

  Future<void> requestAuthentication() async {
    bool authAvailable = await auth.canCheckBiometrics;
    if (!isMobile || !authAvailable) {
      print("Device does not support biometric auth");
      add(AppEventAuthStateChange(authState: AuthState.authenticated));
      return;
    }

    this.authState = AuthState.requesting;
    bool result = await auth.authenticate(
      localizedReason: 'Scan your fingerprint (or face or whatever) to authenticate',
      useErrorDialogs: true,
      stickyAuth: true,
      biometricOnly: false,
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

  AppStateContent _buildContentState({AppTheme? appTheme, AuthState? authState, ChanSingleEvent? event}) {
    return AppStateContent(
      appTheme: appTheme ?? this.appTheme,
      authState: authState ?? this.authState,
      event: event,
    );
  }
}
