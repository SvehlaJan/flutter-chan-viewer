import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/app_bloc/app_bloc.dart';
import 'package:flutter_chan_viewer/bloc/app_bloc/app_event.dart';
import 'package:flutter_chan_viewer/bloc/app_bloc/app_state.dart';
import 'package:flutter_chan_viewer/bloc/chan_viewer_bloc/chan_viewer_bloc.dart';

import 'app.dart';
import 'bloc/simple_bloc_delegate.dart';
import 'utils/constants.dart';

void main() async {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(
    BlocProvider(
      create: (context) {
        return AppBloc()..add(AppEventAppStarted());
      },
      child: MainApp(),
    ),
  );
//  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(builder: (context, state) {
      if (state is AppStateLoading) {
        return Constants.centeredProgressIndicator;
      } else if (state is AppStateContent) {
        ThemeData themeData;
        if (state.appTheme == AppTheme.light) {
          themeData = ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.red,
            cardColor: Colors.white,
            textTheme: TextTheme(
                headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
                title: TextStyle(fontSize: 20.0),
                body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
                body2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
                caption: TextStyle(fontSize: 12.0, fontFamily: 'Hind')),
          );
        } else {
          themeData = ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.red,
            cardColor: Colors.black87,
          );
        }

        return BlocProvider(
          builder: (context) => ChanViewerBloc(),
          child: MaterialApp(
            title: Constants.appName,
            theme: themeData,
            home: ChanViewerApp(),
          ),
        );
      } else {
        return Constants.errorPlaceholder;
      }
    });
  }
}
