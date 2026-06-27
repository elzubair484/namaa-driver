import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure(this.message, {this.code});
  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'خطأ في الاتصال بالشبكة'])
      : super(message, code: 'network_error');
}

class AuthFailure extends Failure {
  const AuthFailure(String message, {super.code}) : super(message);
}

class OtpFailure extends Failure {
  const OtpFailure(String message) : super(message, code: 'otp_error');
}

class ServerFailure extends Failure {
  const ServerFailure(String message, {super.code}) : super(message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(String message) : super(message, code: 'permission_denied');
}

class StorageFailure extends Failure {
  const StorageFailure(String message) : super(message, code: 'storage_error');
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message, code: 'validation_error');
}

class LocationFailure extends Failure {
  const LocationFailure(String message) : super(message, code: 'location_error');
}

class TripFailure extends Failure {
  const TripFailure(String message, {super.code}) : super(message);
}

class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'حدث خطأ غير متوقع'])
      : super(message, code: 'unknown');
}
