import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/models/api/catalog_model.dart';

abstract class BoardDetailState extends Equatable {
  BoardDetailState([List props = const []]) : super(props);
}

class BoardDetailStateLoading extends BoardDetailState {
  @override
  String toString() => 'BoardDetailStateLoading';
}

class BoardDetailStateError extends BoardDetailState {
  final String message;

  BoardDetailStateError(this.message);

  @override
  String toString() => 'BoardDetailStateError { message: $message }';
}

class BoardDetailStateContent extends BoardDetailState {
  final List<ChanCatalogThread> threads;

  BoardDetailStateContent(this.threads)
      : super([
          threads
        ]);

  @override
  String toString() => 'BoardDetailStateContent { threads: ${threads.length} }';
}
