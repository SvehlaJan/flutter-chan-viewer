import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/helper/chan_board_item_wrapper.dart';

class BoardListStateContent extends ChanStateContent {
  final List<ChanBoardItemWrapper> boards;

  const BoardListStateContent({
    required showSearchBar,
    required showLazyLoading,
    required this.boards,
  }) : super(showSearchBar: showSearchBar, showLazyLoading: showLazyLoading);

  @override
  List<Object?> get props => super.props..addAll([boards]);
}
