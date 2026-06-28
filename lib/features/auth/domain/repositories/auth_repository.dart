import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/driver_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, DriverEntity?>> signInWithEmail({
    required String email,
    required String password,
  });
  Future<Either<Failure, DriverEntity?>> getCurrentDriver();
  Future<Either<Failure, void>> signOut();
  Stream<DriverEntity?> watchCurrentDriver();
}
