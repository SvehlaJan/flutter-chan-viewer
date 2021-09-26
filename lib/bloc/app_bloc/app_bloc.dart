import 'dart:async';
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

import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, ChanState> {
  AppBloc() : super(ChanStateLoading());

  LocalAuthentication auth = LocalAuthentication();
  AppLifecycleState lastLifecycleState = AppLifecycleState.inactive;
  AuthState authState = AuthState.not_required;
  AppTheme appTheme = AppTheme.undefined;

  Future<void> initBloc() async {
    await getIt.getAsync<Preferences>();
    await getIt.getAsync<ChanDownloader>();
    await getIt.getAsync<ChanStorage>();
    await getIt.getAsync<ChanRepository>();
  }

  @override
  Stream<ChanState> mapEventToState(AppEvent event) async* {
    try {
      if (event is AppEventAppStarted) {
        await initBloc();
        int appThemeIndex = Preferences.getInt(Preferences.KEY_SETTINGS_THEME) ?? 0;
        appTheme = AppTheme.values[appThemeIndex];
        yield _buildContentState();
      } else if (event is AppEventSetTheme) {
        appTheme = event.appTheme;
        yield _buildContentState();
      } else if (event is AppEventLifecycleChange) {
        this.lastLifecycleState = event.lastLifecycleState;
        print("ChanViewerEventLifecycleChange: ${event.lastLifecycleState}");
        if (event.lastLifecycleState == AppLifecycleState.paused) {
          this.authState = AuthState.auth_required;
          yield _buildContentState();
        } else if (event.lastLifecycleState == AppLifecycleState.resumed && this.authState == AuthState.auth_required) {
          bool result = await auth.authenticate(
            localizedReason: 'Scan your fingerprint (or face or whatever) to authenticate',
            useErrorDialogs: true,
            stickyAuth: true,
            biometricOnly: true,
          );
          if (result) {
            this.authState = AuthState.authenticated;
          } else {
            this.authState = AuthState.forbidden;
          }
          yield _buildContentState();
        }
      }
    } catch (e, stackTrace) {
      ChanLogger.e("Event error!", e, stackTrace);
      yield ChanStateError(e.toString());
    }
  }

  AppStateContent _buildContentState({AppTheme? appTheme, AuthState? authState}) {
    return AppStateContent(
      appTheme: appTheme ?? this.appTheme,
      authState: authState ?? this.authState,
    );
  }
}
