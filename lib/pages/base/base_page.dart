import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';

abstract class BasePageState<T extends StatefulWidget> extends State<T> with SingleTickerProviderStateMixin {
  late Animation<double> _fabAnimation;
  late AnimationController _fabAnimationController;

  TextEditingController _searchQueryController = TextEditingController();
  late Bloc bloc;
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    _fabAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    final curvedAnimation = CurvedAnimation(curve: Curves.easeInOut, parent: _fabAnimationController);
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
    _searchFocusNode = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  String? getPageTitle() => null;

  void finishScreen() async {
    if (await onBackPressed() == true) {
      Navigator.pop(context, false);
    }
  }

  Widget? getPageFab(BuildContext context, List<PageAction>? pageActions) {
    if (pageActions != null && pageActions.isNotEmpty) {
      if (pageActions.length > 1) {
        return FloatingActionBubble(
          items: [...pageActions.map((action) => _makeFabButton(action))],
          animation: _fabAnimation,
          onPress: () {
            _fabAnimationController.isCompleted ? _fabAnimationController.reverse() : _fabAnimationController.forward();
          },
          iconColor: Theme.of(context).primaryIconTheme.color!,
          animatedIconData: AnimatedIcons.menu_close,
          backGroundColor: Theme.of(context).colorScheme.secondary,
        );
      } else {
        return FloatingActionButton(
            onPressed: pageActions[0].onTap as void Function()?, child: Icon(pageActions[0].icon));
      }
    } else {
      return null;
    }
  }

  Bubble _makeFabButton(PageAction action) => Bubble(
        title: action.title,
        iconColor: Theme.of(context).primaryIconTheme.color!,
        bubbleColor: Theme.of(context).colorScheme.secondary,
        icon: action.icon,
        titleStyle: Theme.of(context).textTheme.titleMedium!,
        onPress: () {
          _fabAnimationController.reverse();
          action.onTap();
        },
      );

  /// Return true if stack should pop. False will block the back-press.
  Future<bool> onBackPressed() async {
    return Future.value(true);
  }

  Widget buildScaffold(
    BuildContext context,
    Widget body, {
    Color? backgroundColor,
    FloatingActionButton? fab,
    List<PageAction>? pageActions,
    bool? showSearchBar,
  }) {
    return WillPopScope(
      onWillPop: onBackPressed,
      child: FocusableActionDetector(
        autofocus: true,
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.escape): BackNavigationIntent(),
        },
        actions: {
          BackNavigationIntent: CallbackAction<BackNavigationIntent>(onInvoke: (BackNavigationIntent intent) {
            onBackPressed().then((value) {
              if (value) {
                Navigator.of(context).pop();
              }
            });
            return null;
          }),
        },
        child: Scaffold(
          backgroundColor: backgroundColor != null ? backgroundColor : Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(context, showSearchBar ?? false, getPageTitle()) as PreferredSizeWidget?,
          body: Builder(builder: (BuildContext context) => body),
          floatingActionButton: fab ?? getPageFab(context, pageActions),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ),
      ),
    );
  }

  Widget? _buildAppBar(BuildContext context, bool showSearchBar, String? pageTitle) {
    if (showSearchBar) {
      return AppBar(
        leading: IconButton(icon: Icon(Icons.search), onPressed: finishScreen),
        title: TextField(
          controller: _searchQueryController,
          focusNode: _searchFocusNode,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Search...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white30),
          ),
          onChanged: (query) => updateSearchQuery(query),
        ),
      );
    } else if (pageTitle != null) {
      return AppBar(
        leading: ModalRoute.of(context)!.canPop ? IconButton(icon: BackButtonIcon(), onPressed: finishScreen) : null,
        title: Text(pageTitle),
      );
    } else {
      return null;
    }
  }

  void updateSearchQuery(String newQuery) {
    bloc.add(ChanEventSearch(newQuery));
  }

  void startSearch() {
    bloc.add(ChanEventShowSearch());
    ModalRoute.of(context)!.addLocalHistoryEntry(LocalHistoryEntry(onRemove: () {
      _searchQueryController.clear();
      bloc.add(ChanEventCloseSearch());
    }));
    _searchFocusNode.requestFocus();
  }

  static Widget buildErrorScreen(BuildContext context, String message) {
    return Center(child: Text("Error:\n$message"));
  }

  void showOfflineSnackbar(BuildContext context) {
    final snackBar = SnackBar(content: Text("Failed to fetch content online."));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class BackNavigationIntent extends Intent {}

class PageAction {
  const PageAction(this.title, this.icon, this.onTap);

  final String title;
  final IconData icon;
  final Function onTap;
}
