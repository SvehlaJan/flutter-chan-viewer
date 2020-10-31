import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

abstract class ChanState extends Equatable {
  final bool showSearchBar;

  const ChanState({
    @required this.showSearchBar,
  });

  @override
  List<Object> get props => [showSearchBar];
}

abstract class ChanStateContent extends ChanState {
  final bool showLazyLoading;

  const ChanStateContent({
    @required showSearchBar,
    @required this.showLazyLoading,
  }) : super(showSearchBar: showSearchBar);

  @override
  List<Object> get props => super.props..addAll([showLazyLoading]);
}

class ChanStateLoading extends ChanState {}

class ChanStateError extends ChanState {
  final String message;

  ChanStateError(this.message);

  @override
  List<Object> get props => [message];
}

class ChanStateNotAuthorized extends ChanState {}
