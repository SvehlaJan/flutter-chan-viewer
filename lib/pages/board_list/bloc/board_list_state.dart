import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/helper/chan_board_item_wrapper.dart';

class BoardListStateContent extends ChanState {
  final List<ChanBoardItemWrapper> items;
  final bool lazyLoading;

  BoardListStateContent(this.items, this.lazyLoading);

  @override
  List<Object> get props => [items, lazyLoading];
}
