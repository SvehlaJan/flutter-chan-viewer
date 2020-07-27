import 'package:flutter/foundation.dart';

class ApiException implements Exception {
  final Exception exception;
  final String message;

  const ApiException({
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
