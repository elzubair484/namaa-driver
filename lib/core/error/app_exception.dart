abstract class AppException implements Exception {
  const AppException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class NetworkException extends AppException {
  const NetworkException([String message = 'خطأ في الاتصال بالشبكة'])
      : super(message, code: 'network_error');
}

class AuthException extends AppException {
  const AuthException(String message, {super.code}) : super(message);
}

class OtpException extends AppException {
  const OtpException(String message) : super(message, code: 'otp_error');
}

class ServerException extends AppException {
  const ServerException(String message, {super.code}) : super(message);
}

class PermissionException extends AppException {
  const PermissionException(String message) : super(message, code: 'permission_denied');
}

class StorageException extends AppException {
  const StorageException(String message) : super(message, code: 'storage_error');
}

class ValidationException extends AppException {
  const ValidationException(String message) : super(message, code: 'validation_error');
}

class LocationException extends AppException {
  const LocationException(String message) : super(message, code: 'location_error');
}

class TripException extends AppException {
  const TripException(String message, {super.code}) : super(message);
}
