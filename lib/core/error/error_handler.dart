import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'app_exception.dart';
import 'failure.dart';

abstract final class ErrorHandler {
  static Failure handleException(Object exception) {
    if (exception is Failure) return exception;
    if (exception is AppException) return _fromAppException(exception);

    if (exception is SocketException || exception is HttpException) {
      return const NetworkFailure();
    }
    if (exception is sb.AuthException) {
      return AuthFailure(exception.message);
    }
    if (exception is sb.PostgrestException) {
      return ServerFailure(exception.message, code: exception.code);
    }

    return UnknownFailure(exception.toString());
  }

  static Failure _fromAppException(AppException e) {
    return switch (e) {
      NetworkException() => NetworkFailure(e.message),
      AuthException() => AuthFailure(e.message, code: e.code),
      OtpException() => OtpFailure(e.message),
      ServerException() => ServerFailure(e.message, code: e.code),
      PermissionException() => PermissionFailure(e.message),
      StorageException() => StorageFailure(e.message),
      ValidationException() => ValidationFailure(e.message),
      LocationException() => LocationFailure(e.message),
      TripException() => TripFailure(e.message, code: e.code),
      _ => UnknownFailure(e.message),
    };
  }
}
