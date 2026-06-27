import 'package:equatable/equatable.dart';

enum VehicleType { economy, comfort, suv }

class VehicleEntity extends Equatable {
  const VehicleEntity({
    required this.id,
    required this.driverId,
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.plateNumber,
    required this.vehicleType,
    this.isActive = true,
  });

  final String id;
  final String driverId;
  final String make;
  final String model;
  final int year;
  final String color;
  final String plateNumber;
  final VehicleType vehicleType;
  final bool isActive;

  @override
  List<Object?> get props =>
      [id, driverId, make, model, year, color, plateNumber, vehicleType];
}
