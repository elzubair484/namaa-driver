import '../../domain/entities/trip_entity.dart';

class TripModel extends TripEntity {
  const TripModel({
    required super.id,
    required super.driverId,
    required super.passengerId,
    required super.status,
    required super.pickupAddress,
    required super.dropoffAddress,
    required super.totalFare,
    required super.driverEarnings,
    required super.paymentMethod,
    required super.requestedAt,
    super.distanceKm,
    super.durationMinutes,
    super.passengerName,
    super.passengerPhone,
    super.passengerAvatarUrl,
    super.passengerRating,
    super.acceptedAt,
    super.startedAt,
    super.completedAt,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] as String,
      driverId: json['driver_id'] as String? ?? '',
      passengerId: json['passenger_id'] as String,
      status: TripStatus.fromDb(json['status'] as String?),
      pickupAddress: json['pickup_address'] as String? ?? '',
      dropoffAddress: json['dropoff_address'] as String? ?? '',
      totalFare: (json['total_fare'] as num?)?.toDouble() ?? 0,
      driverEarnings: (json['driver_earnings'] as num?)?.toDouble() ?? 0,
      paymentMethod: json['payment_method'] == 'wallet'
          ? PaymentMethod.wallet
          : PaymentMethod.cash,
      requestedAt: DateTime.tryParse(json['requested_at'] as String? ?? '') ??
          DateTime.now(),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      durationMinutes: json['duration_minutes'] as int?,
      passengerName: json['passenger_name'] as String?,
      passengerPhone: json['passenger_phone'] as String?,
      passengerAvatarUrl: json['passenger_avatar_url'] as String?,
      passengerRating: json['passenger_rating'] as int?,
      acceptedAt:
          DateTime.tryParse(json['accepted_at'] as String? ?? ''),
      startedAt:
          DateTime.tryParse(json['started_at'] as String? ?? ''),
      completedAt:
          DateTime.tryParse(json['completed_at'] as String? ?? ''),
    );
  }
}
