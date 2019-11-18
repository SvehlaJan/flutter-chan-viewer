import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'thread_detail_event.dart';
import 'thread_detail_state.dart';

class ThreadDetailBloc extends Bloc<ThreadDetailEvent, ThreadDetailState> {
  final _repository = ChanRepository.get();
  final String boardId;
  final int threadId;

  ThreadDetailModel _threadDetailModel;
  bool catalogMode = true;
  bool isFavorite = false;

  ThreadDetailBloc(this.boardId, this.threadId);

  @override
  get initialState => ThreadDetailStateLoading();

  get selectedPostIndex => _threadDetailModel.selectedPostIndex;

  set selectedMediaIndex(int mediaIndex) => _threadDetailModel.selectedMediaIndex = mediaIndex;

  set selectedPostId(int postId) => _threadDetailModel.selectedPostId = postId;

  @override
  Stream<ThreadDetailState> mapEventToState(ThreadDetailEvent event) async* {
    try {
      if (event is ThreadDetailEventFetchPosts) {
        yield ThreadDetailStateLoading();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        _threadDetailModel = await _repository.fetchThreadDetail(event.forceFetch, boardId, threadId);
        isFavorite = (prefs.getStringList(Preferences.KEY_FAVORITE_THREADS) ?? []).contains(threadId.toString());
        catalogMode = prefs.getBool(Preferences.KEY_THREAD_CATALOG_MODE) ?? false;

        yield ThreadDetailStateContent(_threadDetailModel, isFavorite, catalogMode);
      }
      if (event is ThreadDetailEventToggleFavorite) {
        yield ThreadDetailStateLoading();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> favoriteThreads = prefs.getStringList(Preferences.KEY_FAVORITE_THREADS) ?? [];

        favoriteThreads.removeWhere((value) => value == threadId.toString());
        isFavorite = !isFavorite;
        if (isFavorite) {
          favoriteThreads.add(threadId.toString());
          await _repository.addThreadToCache(_threadDetailModel);
        }
        prefs.setStringList(Preferences.KEY_FAVORITE_THREADS, favoriteThreads);

        yield ThreadDetailStateContent(_threadDetailModel, isFavorite, catalogMode);
      }
      if (event is ThreadDetailEventToggleCatalogMode) {
        yield ThreadDetailStateLoading();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        catalogMode = !catalogMode;
        prefs.setBool(Preferences.KEY_THREAD_CATALOG_MODE, catalogMode);

        yield ThreadDetailStateContent(_threadDetailModel, isFavorite, catalogMode);
      }
//      if (event is ThreadDetailEventOnPostSelected) {
//        if (event.mediaIndex != null) {
//          _threadDetailModel.selectedMediaIndex = event.mediaIndex;
//        } else {
//          _threadDetailModel.selectedPostId = event.postId;
//        }
//      }
    } catch (o) {
      print("Event error! ${o.toString()}");
      yield ThreadDetailStateError(o.toString());
    }
  }
}
