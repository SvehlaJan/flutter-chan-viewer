import 'package:flutter_chan_viewer/models/ui/board_item_vo.dart';

class ChanBoardItemWrapper {
  ChanBoardItemWrapper({this.chanBoard, this.headerTitle}) : assert(chanBoard != null || headerTitle != null);

  BoardItemVO? chanBoard;
  String? headerTitle;

  bool get isHeader => headerTitle?.isNotEmpty ?? false;
}
