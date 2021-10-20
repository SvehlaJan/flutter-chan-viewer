import 'package:equatable/equatable.dart';

abstract class ChanState extends Equatable {
  final bool showSearchBar;
  final ChanSingleEvent? event;

  const ChanState({this.showSearchBar = false, this.event});

  @override
  List<Object?> get props => [showSearchBar, event];
}

abstract class ChanStateContent extends ChanState {
  final bool showLazyLoading;

  const ChanStateContent({
    required showSearchBar,
    required event,
    required this.showLazyLoading,
  }) : super(showSearchBar: showSearchBar, event: event);

  @override
  List<Object?> get props => super.props..addAll([showLazyLoading]);
}

class ChanStateLoading extends ChanState {}

class ChanStateError extends ChanState {
  final String message;

  ChanStateError(this.message);

  @override
  List<Object?> get props => [message];
}

class ChanStateNotAuthorized extends ChanState {}

class ChanSingleEvent {
  final int val;

  const ChanSingleEvent(this.val);

  static const ChanSingleEvent CLOSE_PAGE = const ChanSingleEvent(0);
  static const ChanSingleEvent SHOW_OFFLINE = const ChanSingleEvent(1);
  static const ChanSingleEvent SHOW_STORAGE_PERM = const ChanSingleEvent(2);
}
