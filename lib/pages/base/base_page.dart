import 'package:flutter/material.dart';

abstract class BasePage extends StatefulWidget {
  BasePage() : super();
}

abstract class BasePageState<T extends BasePage> extends State<T> {
  BuildContext scaffoldContext;

  String getPageTitle() => null;

  FloatingActionButton getPageFab() => null;

  List<Widget> getPageActions() => null;

  void onBackPressed() => Navigator.pop(context, false);

  Widget buildPage(Widget body) {
    bool showAppBar = getPageTitle() != null || getPageActions() != null;
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              leading: ModalRoute.of(context).canPop ? IconButton(icon: BackButtonIcon(), onPressed: onBackPressed) : null,
              title: Text(getPageTitle()),
              actions: getPageActions(),
            )
          : null,
      body: Builder(
        builder: (BuildContext context) {
          scaffoldContext = context;
          return body;
        },
      ),
      floatingActionButton: getPageFab(),
    );
  }
}
