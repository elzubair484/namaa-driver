import 'package:equatable/equatable.dart';

enum DocumentType {
  nationalId,
  driversLicense,
  vehicleRegistration,
  insurance,
  vehicleFront,
  vehicleBack,
  vehicleSide,
}

enum DocumentStatus { pending, approved, rejected }

extension DocumentTypeExt on DocumentType {
  String get key => switch (this) {
        DocumentType.nationalId => 'national_id',
        DocumentType.driversLicense => 'drivers_license',
        DocumentType.vehicleRegistration => 'vehicle_registration',
        DocumentType.insurance => 'insurance',
        DocumentType.vehicleFront => 'vehicle_front',
        DocumentType.vehicleBack => 'vehicle_back',
        DocumentType.vehicleSide => 'vehicle_side',
      };

  String get labelAr => switch (this) {
        DocumentType.nationalId => 'بطاقة الهوية الوطنية',
        DocumentType.driversLicense => 'رخصة القيادة',
        DocumentType.vehicleRegistration => 'تسجيل المركبة',
        DocumentType.insurance => 'وثيقة التأمين',
        DocumentType.vehicleFront => 'صورة المركبة (أمامية)',
        DocumentType.vehicleBack => 'صورة المركبة (خلفية)',
        DocumentType.vehicleSide => 'صورة المركبة (جانبية)',
      };

  bool get isVehiclePhoto => switch (this) {
        DocumentType.vehicleFront ||
        DocumentType.vehicleBack ||
        DocumentType.vehicleSide =>
          true,
        _ => false,
      };
}

class DocumentEntity extends Equatable {
  const DocumentEntity({
    required this.id,
    required this.driverId,
    required this.documentType,
    required this.fileUrl,
    required this.status,
    this.rejectionReason,
    this.expiryDate,
    required this.uploadedAt,
  });

  final String id;
  final String driverId;
  final DocumentType documentType;
  final String fileUrl;
  final DocumentStatus status;
  final String? rejectionReason;
  final DateTime? expiryDate;
  final DateTime uploadedAt;

  bool get isApproved => status == DocumentStatus.approved;
  bool get isRejected => status == DocumentStatus.rejected;
  bool get isPending => status == DocumentStatus.pending;

  @override
  List<Object?> get props => [id, driverId, documentType, fileUrl, status];
}
