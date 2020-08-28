import 'package:dio/dio.dart';
import 'package:flutter_chan_viewer/data/remote/app_exception.dart';

class ErrorMapper {
  static from(Exception e) {
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
      case DioErrorType.SEND_TIMEOUT:
      case DioErrorType.CONNECT_TIMEOUT:
      case DioErrorType.RECEIVE_TIMEOUT:
        return "Falha de conexão, verifique sua internet";
        break;
      case DioErrorType.CANCEL:
        return "Requisição cancelada";
        break;
      case DioErrorType.RESPONSE:
      case DioErrorType.DEFAULT:
      default:
        break;
    }
    if (error.response?.statusCode != null) {
      switch (error.response.statusCode) {
        case 401:
          return "Autorização negada, verifique seu login";
          break;
        case 403:
          return "Ocorreu um erro na sua requisição, verifique os dados e tente novamente";
          break;
        case 404:
          return "Não encontrado";
          break;
        case 500:
          return "Erro interno do servidor";
          break;
        case 503:
          return "O servidor está indisponível no momento, tente novamente";
          break;
        default:
      }
    }
    return "Erro na requisição, tente novamente";
  }
}
