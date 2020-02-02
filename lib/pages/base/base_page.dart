import 'package:flutter/material.dart';

abstract class BasePage extends StatefulWidget {
  BasePage() : super();
}

abstract class BasePageState<T extends BasePage> extends State<T> {
  String getPageTitle() => null;

  FloatingActionButton getPageFab(BuildContext context) => null;

  void onBackPressed() => Navigator.pop(context, false);

  List<AppBarAction> getAppBarActions(BuildContext context) => null;

  Widget buildPage(BuildContext context, Widget body) {
    bool showAppBar = getPageTitle() != null || getAppBarActions(context) != null;
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              leading: ModalRoute.of(context).canPop ? IconButton(icon: BackButtonIcon(), onPressed: onBackPressed) : null,
              title: Text(getPageTitle()),
              actions: _buildAppBarActions(context),
            )
          : null,
      body: Builder(
        builder: (BuildContext context) => body,
      ),
      floatingActionButton: getPageFab(context),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    List<AppBarAction> actions = getAppBarActions(context);
    List<Widget> widgets = List();

    if (actions == null) {
      return widgets;
    } else if (actions.length <= 2) {
      widgets.addAll(actions.map((action) => _makeImageButton(action)));
    } else {
      widgets.add(_makeImageButton(actions[0]));
      widgets.add(_makePopupMenu(actions.skip(1)));
    }
    return widgets;
  }

  Widget _makeImageButton(AppBarAction action) => IconButton(icon: Icon(action.icon), onPressed: () => action.onTap());

  Widget _makePopupMenu(Iterable<AppBarAction> actions) {
    return PopupMenuButton<AppBarAction>(
      onSelected: (action) => action.onTap(),
      itemBuilder: (BuildContext context) => actions.map((AppBarAction action) {
        return PopupMenuItem<AppBarAction>(
            value: action,
            child: Row(children: <Widget>[
              Padding(padding: const EdgeInsets.only(right: 16.0), child: Icon(action.icon, color: Theme.of(context).accentColor)),
              Text(action.title),
            ]));
      }).toList(),
    );
  }
}

class AppBarAction {
  const AppBarAction(this.title, this.icon, this.onTap);

  final String title;
  final IconData icon;
  final Function onTap;
}
