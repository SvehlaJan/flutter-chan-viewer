enum ChanDownloadProgress {
  NOT_STARTED(-1),
  QUEUED(0),
  IN_PROGRESS(1),
  FINISHED(100);

  const ChanDownloadProgress(this.value);

  final int value;
}
