import 'package:geolocator/geolocator.dart';
import '../error/app_exception.dart';

class LocationService {
  static const LocationSettings _settings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

  Future<Position> getCurrentPosition() async {
    await _ensurePermission();
    return Geolocator.getCurrentPosition(
      locationSettings: _settings,
    );
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(locationSettings: _settings);
  }

  Future<void> _ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException('خدمة الموقع معطلة. يرجى تفعيلها من الإعدادات');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const PermissionException('تم رفض إذن الموقع');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw const PermissionException(
          'تم رفض إذن الموقع نهائياً. يرجى تفعيله من إعدادات التطبيق');
    }
  }

  Future<double> distanceBetween({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}
