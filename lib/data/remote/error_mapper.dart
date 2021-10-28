import 'package:flutter_chan_viewer/data/remote/app_exception.dart';

class ErrorMapper {
  static from(Exception? e) {
    if (e is HttpException) {
      return AppException(exception: e, message: _httpError(e));
    } else if (e is AppException) {
      return e;
    } else {
      return AppException(exception: e, message: e.toString());
    }
  }

  static String _httpError(HttpException exception) {
    if (exception.errorCode == 200) {
      return "Not found!";
    }
    return "Uknnown error.";
  }
}
