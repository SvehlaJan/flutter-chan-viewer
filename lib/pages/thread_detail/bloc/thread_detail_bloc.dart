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

  get selectedMediaIndex => _threadDetailModel.selectedMediaIndex;

  set selectedMediaIndex(int mediaIndex) => _threadDetailModel.selectedMediaIndex = mediaIndex;

  set selectedPostId(int postId) => _threadDetailModel.selectedPostId = postId;

  get selectedPostId => _threadDetailModel.selectedPostId;

  @override
  Stream<ThreadDetailState> mapEventToState(ThreadDetailEvent event) async* {
    try {
      if (event is ThreadDetailEventFetchPosts) {
        yield ThreadDetailStateLoading();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        _threadDetailModel = await _repository.fetchThreadDetail(event.forceFetch, boardId, threadId);
        isFavorite = await _repository.isThreadFavorite(threadId);
        catalogMode = prefs.getBool(Preferences.KEY_THREAD_CATALOG_MODE) ?? false;

        yield ThreadDetailStateContent(_threadDetailModel, selectedPostId, isFavorite, catalogMode);
      } else if (event is ThreadDetailEventToggleFavorite) {
        yield ThreadDetailStateLoading();

        isFavorite = !isFavorite;
        if (isFavorite) {
          await _repository.addThreadToFavorites(_threadDetailModel);
        } else {
          await _repository.removeThreadFromFavorites(_threadDetailModel);
        }

        yield ThreadDetailStateContent(_threadDetailModel, selectedPostId, isFavorite, catalogMode);
      } else if (event is ThreadDetailEventToggleCatalogMode) {
        yield ThreadDetailStateLoading();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        catalogMode = !catalogMode;
        prefs.setBool(Preferences.KEY_THREAD_CATALOG_MODE, catalogMode);

        yield ThreadDetailStateContent(_threadDetailModel, selectedPostId, isFavorite, catalogMode);
      }  else if (event is ThreadDetailEventOnPostSelected) {
        if (event.mediaIndex != null) {
          selectedMediaIndex = event.mediaIndex;
        } else if (event.postId != null) {
          selectedPostId = event.postId;
        }

        yield ThreadDetailStateContent(_threadDetailModel, selectedPostId, isFavorite, catalogMode);
      }
    } catch (o) {
      print("Event error! ${o.toString()}");
      yield ThreadDetailStateError(o.toString());
    }
  }
}
