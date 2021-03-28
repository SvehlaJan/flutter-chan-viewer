import 'package:dio/dio.dart';
import 'package:flutter_chan_viewer/data/remote/app_exception.dart';

class ErrorMapper {
  static from(Exception? e) {
    if (e is DioError) {
      return AppException(exception: e, message: _dioError(e));
    } else if (e is HttpException) {
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

  static String _dioError(DioError error) {
    switch (error.type) {
      case DioErrorType.sendTimeout:
      case DioErrorType.connectTimeout:
      case DioErrorType.receiveTimeout:
        return "Falha de conexão, verifique sua internet";
      case DioErrorType.cancel:
        return "Requisição cancelada";
      case DioErrorType.response:
      default:
        break;
    }
    if (error.response?.statusCode != null) {
      switch (error.response!.statusCode) {
        case 401:
          return "Autorização negada, verifique seu login";
        case 403:
          return "Ocorreu um erro na sua requisição, verifique os dados e tente novamente";
        case 404:
          return "Não encontrado";
        case 500:
          return "Erro interno do servidor";
        case 503:
          return "O servidor está indisponível no momento, tente novamente";
        default:
      }
    }
    return "Erro na requisição, tente novamente";
  }
}
