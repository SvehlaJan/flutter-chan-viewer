import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  FavoritesEvent([List props = const []]) : super(props);
}

class FavoritesEventFetchData extends FavoritesEvent {
  FavoritesEventFetchData() : super([]);

  @override
  String toString() => 'FavoritesEventFetchData { }';
}
