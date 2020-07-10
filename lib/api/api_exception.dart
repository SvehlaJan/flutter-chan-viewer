import 'package:flutter/foundation.dart';

class ApiException implements Exception {
  final Exception exception;
  final String message;

  const ApiException({
    @required this.exception,
    @required this.message,
  });
}
