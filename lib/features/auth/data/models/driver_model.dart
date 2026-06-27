import '../../domain/entities/driver_entity.dart';

class DriverModel extends DriverEntity {
  const DriverModel({
    required super.id,
    required super.userId,
    required super.fullName,
    required super.phone,
    required super.status,
    super.email,
    super.avatarUrl,
    super.nationalId,
    super.rejectionReason,
    super.rating,
    super.totalTrips,
    super.acceptanceRate,
    super.completionRate,
    super.isOnline,
    super.locale,
    super.deviceToken,
    required super.createdAt,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      status: _parseStatus(json['status'] as String? ?? 'pending'),
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      nationalId: json['national_id'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalTrips: (json['total_trips'] as int?) ?? 0,
      acceptanceRate: (json['acceptance_rate'] as num?)?.toDouble() ?? 100.0,
      completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 100.0,
      isOnline: json['is_online'] as bool? ?? false,
      locale: json['locale'] as String? ?? 'ar',
      deviceToken: json['device_token'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'phone': phone,
      'status': status.name,
      if (email != null) 'email': email,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (nationalId != null) 'national_id': nationalId,
      if (rejectionReason != null) 'rejection_reason': rejectionReason,
      'rating': rating,
      'total_trips': totalTrips,
      'acceptance_rate': acceptanceRate,
      'completion_rate': completionRate,
      'is_online': isOnline,
      'locale': locale,
      if (deviceToken != null) 'device_token': deviceToken,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static DriverStatus _parseStatus(String value) {
    return switch (value) {
      'pending' => DriverStatus.pending,
      'under_review' => DriverStatus.underReview,
      'approved' => DriverStatus.approved,
      'rejected' => DriverStatus.rejected,
      'suspended' => DriverStatus.suspended,
      'inactive' => DriverStatus.inactive,
      _ => DriverStatus.pending,
    };
  }
}
