import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';

abstract class BasePageState<T extends StatefulWidget> extends State<T> with SingleTickerProviderStateMixin {
  Animation<double> _fabAnimation;
  AnimationController _fabAnimationController;

  TextEditingController _searchQueryController = TextEditingController();

  @override
  void initState() {
    _fabAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    final curvedAnimation = CurvedAnimation(curve: Curves.easeInOut, parent: _fabAnimationController);
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    super.initState();
  }

  String getPageTitle() => null;

  void finishScreen() async {
    if (await onBackPressed() == true) {
      Navigator.pop(context, false);
    }
  }

  List<PageAction> getAppBarActions(BuildContext context) => null;

  Widget getPageFab(BuildContext context) {
    List<PageAction> actions = getAppBarActions(context);
    if (actions != null && actions.length > 1) {
      if (actions.length > 1) {
        return FloatingActionBubble(
          items: [...actions.map((action) => _makeFabButton(action))],
          animation: _fabAnimation,
          onPress: () {
            _fabAnimationController.isCompleted ? _fabAnimationController.reverse() : _fabAnimationController.forward();
          },
          iconColor: Theme.of(context).primaryIconTheme.color,
          animatedIconData: AnimatedIcons.menu_close,
          backGroundColor: Theme.of(context).accentColor,
        );
      } else {
        return FloatingActionButton(onPressed: actions[0].onTap, child: Icon(actions[0].icon));
      }
    } else {
      return null;
    }
  }

  Bubble _makeFabButton(PageAction action) => Bubble(
        title: action.title,
        iconColor: Theme.of(context).primaryIconTheme.color,
        bubbleColor: Theme.of(context).accentColor,
        icon: action.icon,
        titleStyle: Theme.of(context).textTheme.subtitle1,
        onPress: () {
          _fabAnimationController.reverse();
          action.onTap();
        },
      );

  /// Return true if stack should pop. False will block the back-press.
  Future<bool> onBackPressed() async => Future.value(true);

  Widget buildWillPopScope(BuildContext context, Widget body) => WillPopScope(onWillPop: onBackPressed, child: body);

  Widget buildScaffold(BuildContext context, Widget body, {Color backgroundColor, FloatingActionButton fab, List<PageAction> appBarActions, bool showSearchBar = false}) {
    bool showAppBar = getPageTitle() != null || getAppBarActions(context) != null;
    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        backgroundColor: backgroundColor != null ? backgroundColor : Theme.of(context).scaffoldBackgroundColor,
        appBar: showSearchBar
            ? _buildSearchAppBar(context)
            : showAppBar
                ? _buildAppBar(context)
                : null,
        body: Builder(builder: (BuildContext context) => body),
        floatingActionButton: fab ?? getPageFab(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: ModalRoute.of(context).canPop ? IconButton(icon: BackButtonIcon(), onPressed: finishScreen) : null,
      title: Text(getPageTitle()),
      // actions: _buildAppBarActions(context, appBarActions ?? getAppBarActions(context)),
    );
  }

  Widget _buildSearchAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(icon: Icon(Icons.search), onPressed: finishScreen),
      title: TextField(
        controller: _searchQueryController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: "Search...",
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.white30),
        ),
        onChanged: (query) => updateSearchQuery(query),
      ),
      // actions: _buildAppBarActions(context, appBarActions ?? getAppBarActions(context)),
    );
  }

  void updateSearchQuery(String newQuery) {
    throw UnimplementedError();
  }

  void startSearch() {
    ModalRoute.of(context).addLocalHistoryEntry(LocalHistoryEntry(onRemove: cancelSearching));
  }

  void cancelSearching() {
      _searchQueryController.clear();
      updateSearchQuery("");
  }

  static Widget buildErrorScreen(BuildContext context, String message) {
    return Center(child: Text("Error:\n$message"));
  }

  void showOfflineSnackbar(BuildContext context) {
    final snackBar = SnackBar(content: Text("Thread seems to be no longer available."));
    Scaffold.of(context).showSnackBar(snackBar);
  }
}

class PageAction {
  const PageAction(this.title, this.icon, this.onTap);

  final String title;
  final IconData icon;
  final Function onTap;
}
