import 'package:equatable/equatable.dart';

enum DriverStatus {
  pending,
  underReview,
  approved,
  rejected,
  suspended,
  inactive,
}

class DriverEntity extends Equatable {
  const DriverEntity({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.status,
    this.email,
    this.avatarUrl,
    this.nationalId,
    this.rejectionReason,
    this.rating = 5.0,
    this.totalTrips = 0,
    this.acceptanceRate = 100.0,
    this.completionRate = 100.0,
    this.isOnline = false,
    this.locale = 'ar',
    this.deviceToken,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String fullName;
  final String phone;
  final DriverStatus status;
  final String? email;
  final String? avatarUrl;
  final String? nationalId;
  final String? rejectionReason;
  final double rating;
  final int totalTrips;
  final double acceptanceRate;
  final double completionRate;
  final bool isOnline;
  final String locale;
  final String? deviceToken;
  final DateTime createdAt;

  bool get isApproved => status == DriverStatus.approved;
  bool get isPending => status == DriverStatus.pending || status == DriverStatus.underReview;
  bool get isRejected => status == DriverStatus.rejected;

  DriverEntity copyWith({
    String? fullName,
    String? email,
    String? avatarUrl,
    DriverStatus? status,
    String? rejectionReason,
    double? rating,
    int? totalTrips,
    double? acceptanceRate,
    double? completionRate,
    bool? isOnline,
    String? locale,
    String? deviceToken,
  }) {
    return DriverEntity(
      id: id,
      userId: userId,
      fullName: fullName ?? this.fullName,
      phone: phone,
      status: status ?? this.status,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      nationalId: nationalId,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      acceptanceRate: acceptanceRate ?? this.acceptanceRate,
      completionRate: completionRate ?? this.completionRate,
      isOnline: isOnline ?? this.isOnline,
      locale: locale ?? this.locale,
      deviceToken: deviceToken ?? this.deviceToken,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        fullName,
        phone,
        status,
        email,
        avatarUrl,
        nationalId,
        rating,
        totalTrips,
        isOnline,
        locale,
      ];
}
