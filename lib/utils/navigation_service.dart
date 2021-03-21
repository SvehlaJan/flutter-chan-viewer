import 'package:flutter/material.dart';
import 'package:flutter_chan_viewer/utils/navigation_helper.dart';

class NavigationService {
  GlobalKey<NavigatorState> _navigationKey = GlobalKey<NavigatorState>();

  GlobalKey<NavigatorState> get navigationKey => _navigationKey;

  void pop() {
    return _navigationKey.currentState!.pop();
  }

  Future<dynamic> navigateTo(String routeName, {Map<String, dynamic>? arguments, clearStack = false}) {
    Route? route = NavigationHelper.getRoute(routeName, arguments);
    return clearStack ? _navigationKey.currentState!.pushReplacement(route!) : _navigationKey.currentState!.push(route!);
  }
}
