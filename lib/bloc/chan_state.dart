import 'package:equatable/equatable.dart';

abstract class ChanState extends Equatable {
  ChanState();

  @override
  List<Object> get props => [];
}

class ChanStateLoading extends ChanState {}

class ChanStateError extends ChanState {
  final String message;

  ChanStateError(this.message);

  @override
  List<Object> get props => [message];
}

class ChanStateNotAuthorized extends ChanState {}
