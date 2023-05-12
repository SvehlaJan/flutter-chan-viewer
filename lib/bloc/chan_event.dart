import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/repositories/chan_result.dart';

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
