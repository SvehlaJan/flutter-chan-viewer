import 'package:flutter_chan_viewer/models/board_list_model.dart';

class ChanBoardItemWrapper {
  ChanBoardItemWrapper({this.chanBoard, this.headerTitle}) : assert(chanBoard != null || headerTitle != null);

  ChanBoard chanBoard;
  String headerTitle;

  bool get isHeader => headerTitle?.isNotEmpty ?? false;
}
