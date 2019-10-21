import 'package:equatable/equatable.dart';

abstract class AppState extends Equatable {
  AppState([List props = const []]) : super(props);
}

class AppStateLoading extends AppState {
  @override
  String toString() => 'BoardListStateLoading';
}

class AppStateError extends AppState {
  final String message;

  AppStateError(this.message);

  @override
  String toString() => 'BoardListStateError { message: $message }';
}

class AppStateContent extends AppState {
  final showBottomBar;

  AppStateContent(this.showBottomBar)
      : super([
          showBottomBar,
        ]);

  @override
  String toString() => 'BoardListStateContent { showBottomBar: $showBottomBar }';
}
