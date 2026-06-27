import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../auth/domain/entities/driver_entity.dart';
import '../entities/vehicle_entity.dart';
import '../entities/document_entity.dart';

abstract class OnboardingRepository {
  Future<Either<Failure, DriverEntity>> createDriverProfile({
    required String fullName,
    required String phone,
    String? email,
  });

  Future<Either<Failure, DriverEntity>> updateDriverProfile({
    required String driverId,
    String? fullName,
    String? email,
    String? avatarUrl,
  });

  Future<Either<Failure, String>> uploadAvatar({
    required String userId,
    required dynamic imageFile,
  });

  Future<Either<Failure, VehicleEntity>> saveVehicle({
    required String driverId,
    required String make,
    required String model,
    required int year,
    required String color,
    required String plateNumber,
    required VehicleType vehicleType,
  });

  Future<Either<Failure, String>> uploadDocument({
    required String userId,
    required DocumentType documentType,
    required dynamic file,
  });

  Future<Either<Failure, DocumentEntity>> saveDocument({
    required String driverId,
    required DocumentType documentType,
    required String fileUrl,
    DateTime? expiryDate,
  });

  Future<Either<Failure, List<DocumentEntity>>> getDocuments(String driverId);

  Future<Either<Failure, DriverEntity>> submitForReview(String driverId);
}
