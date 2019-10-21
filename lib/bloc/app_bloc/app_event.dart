import 'package:equatable/equatable.dart';

abstract class AppEvent extends Equatable {
  AppEvent([List props = const []]) : super(props);
}

class AppEventAppStarted extends AppEvent {
  @override
  String toString() => 'AppEventAppStarted { }';
}

class AppEventShowBottomBar extends AppEvent {
  final bool showBottomBar;

  AppEventShowBottomBar(this.showBottomBar);

  @override
  String toString() => 'AppEventShowBottomBar { showBottomBar: $showBottomBar }';
}