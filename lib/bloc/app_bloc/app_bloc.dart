import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/models/api/boards_model.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final _repository = ChanRepository.get();

  AppBloc();

  void initBloc() {}

  @override
  get initialState => AppStateLoading();

  @override
  Stream<AppState> mapEventToState(AppEvent event) async* {
    print("Event received! ${event.toString()}");
    print("Current state! ${currentState.toString()}");
    try {
      if (event is AppEventAppStarted) {
        initBloc();
        yield AppStateContent(true);
      }
      if (event is AppEventShowBottomBar) {
        yield AppStateContent(event.showBottomBar);
      }
    } catch (o) {
      print("Event error! ${o.toString()}");
      yield AppStateError(o.toString());
    }
  }
}
