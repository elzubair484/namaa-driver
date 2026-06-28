import 'package:dartz/dartz.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/driver_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../sources/auth_remote_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);
  final AuthRemoteSource _remote;

  @override
  Future<Either<Failure, DriverEntity?>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final driver = await _remote.signInWithEmail(
        email: email,
        password: password,
      );
      return Right(driver);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, DriverEntity?>> getCurrentDriver() async {
    try {
      final driver = await _remote.getCurrentDriver();
      return Right(driver);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remote.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Stream<DriverEntity?> watchCurrentDriver() {
    return _remote.watchCurrentDriver();
  }
}
