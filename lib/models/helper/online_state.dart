/**
 * WARNING!!!
 * Keep this in sync with [OnlineStateDb] in threads_table.dart .
 * It needs to be there because of code generation.
 */
enum OnlineState { ONLINE, ARCHIVED, NOT_FOUND, CUSTOM, UNKNOWN }

extension on OnlineState {}
