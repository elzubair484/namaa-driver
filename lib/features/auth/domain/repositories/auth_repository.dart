import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/driver_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> sendOtp(String phone);
  Future<Either<Failure, DriverEntity?>> verifyOtp({
    required String phone,
    required String otp,
  });
  Future<Either<Failure, DriverEntity?>> getCurrentDriver();
  Future<Either<Failure, void>> signOut();
  Stream<DriverEntity?> watchCurrentDriver();
}
