import '../../domain/entities/document_entity.dart';

class DocumentModel extends DocumentEntity {
  const DocumentModel({
    required super.id,
    required super.driverId,
    required super.documentType,
    required super.fileUrl,
    required super.status,
    super.rejectionReason,
    super.expiryDate,
    required super.uploadedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String,
      driverId: json['driver_id'] as String,
      documentType: _parseType(json['document_type'] as String),
      fileUrl: json['file_url'] as String,
      status: _parseStatus(json['status'] as String? ?? 'pending'),
      rejectionReason: json['rejection_reason'] as String?,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : null,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'driver_id': driverId,
        'document_type': documentType.key,
        'file_url': fileUrl,
        'status': status.name,
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
        if (expiryDate != null) 'expiry_date': expiryDate!.toIso8601String(),
      };

  static DocumentType _parseType(String v) => switch (v) {
        'national_id' => DocumentType.nationalId,
        'drivers_license' => DocumentType.driversLicense,
        'vehicle_registration' => DocumentType.vehicleRegistration,
        'insurance' => DocumentType.insurance,
        'vehicle_front' => DocumentType.vehicleFront,
        'vehicle_back' => DocumentType.vehicleBack,
        'vehicle_side' => DocumentType.vehicleSide,
        _ => DocumentType.nationalId,
      };

  static DocumentStatus _parseStatus(String v) => switch (v) {
        'approved' => DocumentStatus.approved,
        'rejected' => DocumentStatus.rejected,
        _ => DocumentStatus.pending,
      };
}
