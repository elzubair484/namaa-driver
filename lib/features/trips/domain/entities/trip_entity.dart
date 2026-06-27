import 'package:equatable/equatable.dart';

enum TripStatus {
  requested,
  accepted,
  driverArriving,
  arrived,
  inProgress,
  completed,
  cancelled;

  String get dbValue => switch (this) {
        TripStatus.requested => 'requested',
        TripStatus.accepted => 'accepted',
        TripStatus.driverArriving => 'driver_arriving',
        TripStatus.arrived => 'arrived',
        TripStatus.inProgress => 'in_progress',
        TripStatus.completed => 'completed',
        TripStatus.cancelled => 'cancelled',
      };

  static TripStatus fromDb(String? s) => switch (s) {
        'accepted' => TripStatus.accepted,
        'driver_arriving' => TripStatus.driverArriving,
        'arrived' => TripStatus.arrived,
        'in_progress' => TripStatus.inProgress,
        'completed' => TripStatus.completed,
        'cancelled' => TripStatus.cancelled,
        _ => TripStatus.requested,
      };
}

enum PaymentMethod { cash, wallet }

class TripEntity extends Equatable {
  const TripEntity({
    required this.id,
    required this.driverId,
    required this.passengerId,
    required this.status,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.totalFare,
    required this.driverEarnings,
    required this.paymentMethod,
    required this.requestedAt,
    this.distanceKm,
    this.durationMinutes,
    this.passengerName,
    this.passengerPhone,
    this.passengerAvatarUrl,
    this.passengerRating,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
  });

  final String id;
  final String driverId;
  final String passengerId;
  final TripStatus status;
  final String pickupAddress;
  final String dropoffAddress;
  final double totalFare;
  final double driverEarnings;
  final PaymentMethod paymentMethod;
  final DateTime requestedAt;
  final double? distanceKm;
  final int? durationMinutes;
  final String? passengerName;
  final String? passengerPhone;
  final String? passengerAvatarUrl;
  final int? passengerRating;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  TripEntity copyWith({
    TripStatus? status,
    int? passengerRating,
    DateTime? acceptedAt,
    DateTime? startedAt,
    DateTime? completedAt,
  }) =>
      TripEntity(
        id: id,
        driverId: driverId,
        passengerId: passengerId,
        status: status ?? this.status,
        pickupAddress: pickupAddress,
        dropoffAddress: dropoffAddress,
        totalFare: totalFare,
        driverEarnings: driverEarnings,
        paymentMethod: paymentMethod,
        requestedAt: requestedAt,
        distanceKm: distanceKm,
        durationMinutes: durationMinutes,
        passengerName: passengerName,
        passengerPhone: passengerPhone,
        passengerAvatarUrl: passengerAvatarUrl,
        passengerRating: passengerRating ?? this.passengerRating,
        acceptedAt: acceptedAt ?? this.acceptedAt,
        startedAt: startedAt ?? this.startedAt,
        completedAt: completedAt ?? this.completedAt,
      );

  @override
  List<Object?> get props => [id, status, passengerRating];
}
