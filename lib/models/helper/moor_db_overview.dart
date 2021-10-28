class MoorDbOverview {
  List<MoorBoardOverview> boards = [];
}

class MoorBoardOverview {
  final String? boardId;
  final int onlineCount;
  final int archivedCount;
  final int notFoundCount;
  final int unknownCount;

  MoorBoardOverview(this.boardId, this.onlineCount, this.archivedCount,
      this.notFoundCount, this.unknownCount);
}
