import 'package:logger/logger.dart';

mixin ChanLogger {
  late final Logger _logger = getLogger();

  Logger getLogger() {
    return Logger(printer: SimpleLogPrinter());
  }

  void logDebug(dynamic message, {Object? error, StackTrace? stackTrace}) {
    log(Level.debug, message, error: error, stackTrace: stackTrace);
  }

  void logInfo(dynamic message, {Object? error, StackTrace? stackTrace}) {
    log(Level.info, message, error: error, stackTrace: stackTrace);
  }

  void logWarning(dynamic message, {Object? error, StackTrace? stackTrace}) {
    log(Level.warning, message, error: error, stackTrace: stackTrace);
  }

  void logError(dynamic message, {Object? error, StackTrace? stackTrace}) {
    log(Level.error, message, error: error, stackTrace: stackTrace);
  }

  void log(Level level, dynamic message, {Object? error, StackTrace? stackTrace}) {
    final _stackTrace = stackTrace ?? (error is Error ? error.stackTrace : null);
    _logger.log(level, message, error: error, stackTrace: _stackTrace);
  }
}

class SimpleLogPrinter extends SimplePrinter {
  // @override
  // List<String> log(LogEvent event) {
  //   print(event.message);
  //   return [event.message ?? ""];
  // }
}