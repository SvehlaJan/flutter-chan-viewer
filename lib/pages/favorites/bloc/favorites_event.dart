import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  FavoritesEvent();

  @override
  List<Object> get props => [];
}

class FavoritesEventFetchData extends FavoritesEvent {}
