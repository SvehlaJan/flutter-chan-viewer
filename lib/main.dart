import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/app_bloc/app_bloc.dart';
import 'package:flutter_chan_viewer/bloc/app_bloc/app_event.dart';
import 'package:flutter_chan_viewer/bloc/app_bloc/app_state.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/bloc/chan_viewer_bloc/chan_viewer_bloc.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/utils/flavor_config.dart';
import 'package:flutter_chan_viewer/utils/theme_helper.dart';

import 'app.dart';
import 'utils/constants.dart';

void main() async {
  EquatableConfig.stringify = true;
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();

  getIt.allReady().then((value) {
    runApp(
      BlocProvider(
        create: (context) {
          return AppBloc()..add(AppEventAppStarted());
        },
        child: MainApp(),
      ),
    );
  });
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FlavorConfig(
      flavor: Flavor.dev,
//      color: flavor == Flavor.dev ? Colors.green : Colors.deepPurpleAccent,
      values: Constants.flavorDev,
    );

    return BlocBuilder<AppBloc, ChanState>(builder: (context, state) {
      if (state is ChanStateLoading) {
        return Constants.centeredProgressIndicator;
      } else if (state is AppStateContent) {
        ThemeData themeData;
        if (state.appTheme == AppTheme.light) {
          themeData = ThemeHelper.getThemeLight(context);
        } else {
          themeData = ThemeHelper.getThemeDark(context);
        }

        return BlocProvider(
          create: (context) => ChanViewerBloc(),
          child: MaterialApp(
            title: Constants.appName,
            theme: themeData,
            home: ChanViewerApp(),
          ),
        );
      } else {
        return BasePageState.buildErrorScreen(context, (state as ChanStateError).message);
      }
    });
  }
}
