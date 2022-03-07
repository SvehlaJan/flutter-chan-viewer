class CacheDirective {
  final String boardId;
  final int threadId;
  static const String DIVIDER = "_";

  CacheDirective(this.boardId, this.threadId);

  String getCacheKey() => "$boardId$threadId";

  static CacheDirective fromPath(String path) {
    int dividerIndex = path.indexOf(RegExp(r"\d"));
    return new CacheDirective(path.substring(0, dividerIndex),
        int.parse(path.substring(dividerIndex)));
  }

  String toPath() => "$boardId$DIVIDER$threadId";

  @override
  String toString() {
    return "CacheDirective { boardId: $boardId, threadId: $threadId }";
  }
}
