import 'package:geolocator/geolocator.dart';

enum PermissionStatus { granted, denied, deniedForever, restricted }

abstract final class PermissionService {
  static Future<PermissionStatus> checkLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return PermissionStatus.denied;

    final permission = await Geolocator.checkPermission();
    return switch (permission) {
      LocationPermission.always || LocationPermission.whileInUse => PermissionStatus.granted,
      LocationPermission.deniedForever => PermissionStatus.deniedForever,
      _ => PermissionStatus.denied,
    };
  }

  static Future<PermissionStatus> requestLocation() async {
    final permission = await Geolocator.requestPermission();
    return switch (permission) {
      LocationPermission.always || LocationPermission.whileInUse => PermissionStatus.granted,
      LocationPermission.deniedForever => PermissionStatus.deniedForever,
      _ => PermissionStatus.denied,
    };
  }

  static Future<void> openAppSettings() => Geolocator.openAppSettings();
  static Future<void> openLocationSettings() => Geolocator.openLocationSettings();
}
