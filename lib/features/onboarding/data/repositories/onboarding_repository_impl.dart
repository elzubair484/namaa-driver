import 'package:dartz/dartz.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../../../auth/domain/entities/driver_entity.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../sources/onboarding_remote_source.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl(this._remote);
  final OnboardingRemoteSource _remote;

  @override
  Future<Either<Failure, DriverEntity>> createDriverProfile({
    required String fullName,
    required String phone,
    String? email,
  }) async {
    try {
      final driver = await _remote.createDriverProfile(
        fullName: fullName,
        phone: phone,
        email: email,
      );
      return Right(driver);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, DriverEntity>> updateDriverProfile({
    required String driverId,
    String? fullName,
    String? email,
    String? avatarUrl,
  }) async {
    try {
      final driver = await _remote.updateDriverProfile(
        driverId: driverId,
        fullName: fullName,
        email: email,
        avatarUrl: avatarUrl,
      );
      return Right(driver);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar({
    required String userId,
    required dynamic imageFile,
  }) async {
    try {
      final url = await _remote.uploadAvatar(userId: userId, file: imageFile);
      return Right(url);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> saveVehicle({
    required String driverId,
    required String make,
    required String model,
    required int year,
    required String color,
    required String plateNumber,
    required VehicleType vehicleType,
  }) async {
    try {
      final vehicle = await _remote.saveVehicle(
        driverId: driverId,
        make: make,
        model: model,
        year: year,
        color: color,
        plateNumber: plateNumber,
        vehicleType: vehicleType,
      );
      return Right(vehicle);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, String>> uploadDocument({
    required String userId,
    required DocumentType documentType,
    required dynamic file,
  }) async {
    try {
      final url = await _remote.uploadDocument(
        userId: userId,
        documentType: documentType,
        file: file,
      );
      return Right(url);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, DocumentEntity>> saveDocument({
    required String driverId,
    required DocumentType documentType,
    required String fileUrl,
    DateTime? expiryDate,
  }) async {
    try {
      final doc = await _remote.saveDocument(
        driverId: driverId,
        documentType: documentType,
        fileUrl: fileUrl,
        expiryDate: expiryDate,
      );
      return Right(doc);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<DocumentEntity>>> getDocuments(
      String driverId) async {
    try {
      final docs = await _remote.getDocuments(driverId);
      return Right(docs);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, DriverEntity>> submitForReview(
      String driverId) async {
    try {
      final driver = await _remote.submitForReview(driverId);
      return Right(driver);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
}
