import 'package:logger/logger.dart';

class LogUtils {
  static Logger getLogger() {
    return Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 8,
        lineLength: 100,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
    );
  }
}
