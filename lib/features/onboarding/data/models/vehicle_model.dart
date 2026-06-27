import '../../domain/entities/vehicle_entity.dart';

class VehicleModel extends VehicleEntity {
  const VehicleModel({
    required super.id,
    required super.driverId,
    required super.make,
    required super.model,
    required super.year,
    required super.color,
    required super.plateNumber,
    required super.vehicleType,
    super.isActive,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String,
      driverId: json['driver_id'] as String,
      make: json['make'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      color: json['color'] as String,
      plateNumber: json['plate_number'] as String,
      vehicleType: _parseType(json['vehicle_type'] as String? ?? 'economy'),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'driver_id': driverId,
        'make': make,
        'model': model,
        'year': year,
        'color': color,
        'plate_number': plateNumber,
        'vehicle_type': vehicleType.name,
        'is_active': isActive,
      };

  static VehicleType _parseType(String v) => switch (v) {
        'comfort' => VehicleType.comfort,
        'suv' => VehicleType.suv,
        _ => VehicleType.economy,
      };
}
