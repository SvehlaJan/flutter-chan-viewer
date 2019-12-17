import 'dart:async';
import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/models/board_list_model.dart';
import 'package:flutter_chan_viewer/models/board_detail_model.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final _repository = ChanRepository.getSync();

  @override
  get initialState => FavoritesStateLoading();

  @override
  Stream<FavoritesState> mapEventToState(FavoritesEvent event) async* {
    print("Event received! ${event.toString()}");
    print("Current state! ${state.toString()}");
    try {
      if (event is FavoritesEventFetchData) {
        yield FavoritesStateLoading();

        HashMap<String, List<ThreadDetailModel>> threadMap = await _repository.getFavoriteThreads();
        yield FavoritesStateContent(threadMap);
      }
    } catch (o) {
      print("Event error! ${o.toString()}");
      yield FavoritesStateError(o.toString());
    }
  }
}
