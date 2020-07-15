import 'dart:collection';

import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';

class FavoritesStateContent extends ChanState {
  final HashMap<String, List<ThreadDetailModel>> threadMap;

  FavoritesStateContent(this.threadMap);

  @override
  List<Object> get props => [threadMap];
}
