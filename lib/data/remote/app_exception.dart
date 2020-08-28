import 'package:flutter/foundation.dart';

class AppException implements Exception {
  final Exception exception;
  final String message;

  const AppException({
    @required this.exception,
    @required this.message,
  });
}

class HttpException implements Exception {
  final String message;
  final int errorCode;

  const HttpException({
    @required this.message,
    @required this.errorCode,
  });
}
