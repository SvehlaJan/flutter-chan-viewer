import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/models/posts_model.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'thread_detail_event.dart';
import 'thread_detail_state.dart';

class ThreadDetailBloc extends Bloc<ThreadDetailEvent, ThreadDetailState> {
  final _repository = ChanRepository.get();
  final String boardId;
  final int threadId;

  PostsModel _postsModel;
  bool _catalogMode = true;
  bool _isFavorite = false;

  ThreadDetailBloc(this.boardId, this.threadId);

  @override
  get initialState => ThreadDetailStateLoading();

  @override
  Stream<ThreadDetailState> mapEventToState(ThreadDetailEvent event) async* {
    print("Event received! ${event.toString()}");
    print("Current state! ${currentState.toString()}");
    try {
      if (event is ThreadDetailEventFetchPosts) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        _postsModel = await _repository.fetchPosts(event.forceFetch, boardId, threadId);
        _isFavorite = (prefs.getStringList(Preferences.KEY_FAVORITE_THREADS) ?? []).contains(threadId.toString());
        _catalogMode = prefs.getBool(Preferences.KEY_THREAD_CATALOG_MODE) ?? false;

        yield ThreadDetailStateContent(_postsModel, _isFavorite, _catalogMode);
      }
      if (event is ThreadDetailEventToggleFavorite) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> favoriteThreads = prefs.getStringList(Preferences.KEY_FAVORITE_THREADS) ?? [];

        favoriteThreads.removeWhere((value) => value == threadId.toString());
        _isFavorite = !_isFavorite;
        if (_isFavorite) {
          favoriteThreads.add(threadId.toString());
        }
        prefs.setStringList(Preferences.KEY_FAVORITE_THREADS, favoriteThreads);

        yield ThreadDetailStateContent(_postsModel, _isFavorite, _catalogMode);
      }
      if (event is ThreadDetailEventToggleCatalogMode) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        _catalogMode = !_catalogMode;
        prefs.setBool(Preferences.KEY_THREAD_CATALOG_MODE, _catalogMode);

        yield ThreadDetailStateContent(_postsModel, _isFavorite, _catalogMode);
      }
    } catch (o) {
      print("Event error! ${o.toString()}");
      yield ThreadDetailStateError(o.toString());
    }
  }
}
