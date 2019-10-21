import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/app_bloc/app_bloc.dart';
import 'package:flutter_chan_viewer/bloc/app_bloc/app_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'bloc/simple_bloc_delegate.dart';
import 'utils/constants.dart';
import 'utils/preferences.dart';

void main() async {
  print("main.dart: main start");
  BlocSupervisor.delegate = SimpleBlocDelegate();
  print("main.dart: main 1");
  await Preferences.load();
  print("main.dart: main 2");
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  MainApp();

  @override
  State<StatefulWidget> createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  AppTheme _appTheme;

  MainAppState();

  @override
  void initState() {
    super.initState();
    print("MainAppState: initState");

    SharedPreferences.getInstance().then((prefs) {
      int appThemeIndex = prefs.getInt(Preferences.KEY_SETTINGS_THEME) ?? 0;
      setAppTheme(AppTheme.values[appThemeIndex]);
    });
  }

  void setAppTheme(AppTheme newAppTheme) {
    setState(() {
      _appTheme = newAppTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("MainAppState: build: Using theme: $_appTheme");

    if (_appTheme == null) {
      return Container();
    }

    ThemeData themeData;
    if (_appTheme == AppTheme.light) {
      themeData = ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.red,
        primaryColorLight: Colors.red.shade100,
        accentColor: Colors.indigo,
        cardColor: Colors.white,
        textTheme: TextTheme(headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold), title: TextStyle(fontSize: 20.0), body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind'), body2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'), caption: TextStyle(fontSize: 12.0, fontFamily: 'Hind')),
      );
    } else {
      themeData = ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.red,
        primaryColorLight: Colors.red,
        accentColor: Colors.indigo,
        cardColor: Colors.black87,
        textTheme: TextTheme(
//          headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
//          title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
//          body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
            ),
      );
    }

    return BlocProvider<AppBloc>(
        builder: (context) => AppBloc(),
        child: MaterialApp(
          title: Constants.appName,
          theme: themeData,
          home: ChanViewerApp(),
        ));
  }
}
