import 'package:flutter_chan_viewer/utils/preferences.dart';

class DatabaseHelper {
  // TODO - move to DB
  static int nextPostId() {
    int postId = Preferences.getInt(Preferences.KEY_NEXT_POST_ID, def: 0);
    Preferences.setInt(Preferences.KEY_NEXT_POST_ID, postId + 1);
    return postId;
  }

  // TODO - move to DB
  static int nextThreadId() {
    int threadId = Preferences.getInt(Preferences.KEY_NEXT_THREAD_ID, def: 0);
    Preferences.setInt(Preferences.KEY_NEXT_THREAD_ID, threadId + 1);
    return threadId;
  }
}