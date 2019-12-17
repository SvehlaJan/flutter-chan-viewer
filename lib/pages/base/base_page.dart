import 'package:flutter/material.dart';

abstract class BasePage extends StatefulWidget {
  BasePage() : super();
}

abstract class BasePageState<T extends BasePage> extends State<T> {
  String getPageTitle() => null;

  FloatingActionButton getPageFab(BuildContext context) => null;

  List<Widget> getPageActions(BuildContext context) => null;

  void onBackPressed() => Navigator.pop(context, false);

  Widget buildPage(BuildContext context, Widget body) {
    bool showAppBar = getPageTitle() != null || getPageActions(context) != null;
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              leading: ModalRoute.of(context).canPop ? IconButton(icon: BackButtonIcon(), onPressed: onBackPressed) : null,
              title: Text(getPageTitle()),
              actions: getPageActions(context),
            )
          : null,
      body: Builder(
        builder: (BuildContext context) => body,
      ),
      floatingActionButton: getPageFab(context),
    );
  }
}
