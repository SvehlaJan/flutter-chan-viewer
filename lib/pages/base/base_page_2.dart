import 'package:flutter/material.dart';

abstract class BasePage extends StatefulWidget {
  BasePage() : super();
}

abstract class BasePageState<T extends BasePage> extends State<T> {
  BuildContext scaffoldContext;

  Widget buildPage(Widget body, {String title, List<Widget> actions, FloatingActionButton fab}) {
    bool showAppBar = title != null || actions != null;
    return Scaffold(
      appBar: showAppBar ? AppBar(title: Text(title), actions: actions) : null,
      body: Builder(
        builder: (BuildContext context) {
          scaffoldContext = context;
          return body;
        },
      ),
      floatingActionButton: fab,
    );
  }
}
