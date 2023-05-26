import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/repositories/chan_result.dart';

mixin class ChanEventMixin {}

class ChanEventInitBlocNew extends ChanEventMixin with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class ChanEventFetchDataNew extends ChanEventMixin with EquatableMixin {
  final bool forceRefresh;

  ChanEventFetchDataNew({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class ChanEventDataFetchedNew<T> extends ChanEventMixin with EquatableMixin {
  final DataResult<T> result;

  ChanEventDataFetchedNew(this.result);

  @override
  List<Object?> get props => [result];
}

class ChanEventDataErrorNew<T> extends ChanEventMixin with EquatableMixin {
  final T error;

  ChanEventDataErrorNew(this.error);

  @override
  List<Object?> get props => [error];
}

class ChanEventShowSearchNew extends ChanEventMixin with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class ChanEventCloseSearchNew extends ChanEventMixin with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class ChanEventSearchNew extends ChanEventMixin with EquatableMixin {
  final String query;

  ChanEventSearchNew(this.query);

  @override
  List<Object?> get props => [query];
}

//////////////////////////////////////////////////////////////////////////////////////////////////

abstract class ChanEvent extends Equatable {
  const ChanEvent();

  @override
  List<Object?> get props => [];
}

class ChanEventInitBloc extends ChanEvent {}

class ChanEventFetchData extends ChanEvent {
  final bool forceRefresh;

  ChanEventFetchData({this.forceRefresh = false});

  @override
  List<Object?> get props => super.props..addAll([forceRefresh]);
}

class ChanEventDataFetched<T> extends ChanEvent {
  final DataResult<T> result;

  ChanEventDataFetched(this.result);

  @override
  List<Object?> get props => super.props..addAll([result]);
}

class ChanEventDataError<T> extends ChanEvent {
  final T error;

  ChanEventDataError(this.error);

  @override
  List<Object?> get props => super.props..addAll([error]);
}

class ChanEventShowSearch extends ChanEvent {}

class ChanEventCloseSearch extends ChanEvent {}

class ChanEventSearch extends ChanEvent {
  final String query;

  ChanEventSearch(this.query);

  @override
  List<Object?> get props => super.props..addAll([query]);
}
