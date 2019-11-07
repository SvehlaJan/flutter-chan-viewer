class CacheDirective {
  final String boardId;
  final String threadId;

  CacheDirective(this.boardId, this.threadId);

  String getCachePath() => "$boardId/$threadId/";
}