import 'dart:async';

import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/repositories/chan_repository.dart';

class NewChanRepository {
  static final NewChanRepository _instance = NewChanRepository._internal();
  static bool _initialized = false;
  final ChanRepository _repository = getIt<ChanRepository>();

  static Future<NewChanRepository> initAndGet() async {
    if (_initialized) return _instance;

    _initialized = true;
    return _instance;
  }

  NewChanRepository._internal() {
    // initialization code
  }

//  Stream<Resource<ThreadDetailModel>> threadDetailsStream(String boardId, int threadId) {
//    return NetworkBoundResources<ThreadDetailModel, ThreadDetailModel>().asStream(
//      loadFromDb: () => _repository.listenToLocalThreadDetail(CacheDirective(boardId, threadId)),
//      shouldFetch: (data) => data == null,
//      createCall: () => _repository.fetchRemoteThreadDetail(boardId, threadId, false),
//      processResponse: (result) => result,
//      saveCallResult: (model) => _repository.saveThreadDetail(model),
//    );
//  }

//  @override
//  Future<Resource<List<PostItem>>> getToDoList() async {
//    return NetworkBoundResources<List<PostItem>, List<PostItem>>().asFuture(
//      loadFromDb: _localDataSource.getToDoList,
//      shouldFetch: (data) => data == null || data.isEmpty,
//      createCall: _remoteDataSource.getPendingToDoItems,
//      saveCallResult: _localDataSource.saveToDoItemList,
//    );
//  }

//  @override
//  Future<Resource<PostItem>> setTodoItemAsFinished(PostItem toDoItem) async {
//    return NetworkBoundResources<PostItem, PostItem>().asFuture(
//      loadFromDb: () => toDoItem.copyWith(isDone: !toDoItem.isDone),
//      shouldFetch: (data) => true,
//      createCall: () =>
//          _remoteDataSource.setTodoItemAsFinished(
//              toDoItem
//                  .copyWith(isDone: !toDoItem.isDone)
//                  .toJson),
//      saveCallResult: _localDataSource.updateToDoItem,
//    );
//  }
//
//  @override
//  Future<Resource<PostItem>> addNewToDoItem(PostItem toDoItem) async {
//    return Resource.asFuture<PostItem>(() async =>
//    await _remoteDataSource
//        .addNewToDoItem(toDoItem.toJson)
//        .then(_localDataSource.saveToDoItem));
//  }
}
