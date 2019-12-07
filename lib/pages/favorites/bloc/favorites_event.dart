import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  FavoritesEvent();
}

class FavoritesEventFetchData extends FavoritesEvent {
  FavoritesEventFetchData();

  @override
  String toString() => 'FavoritesEventFetchData { }';

  @override
  List<Object> get props => [];
}
