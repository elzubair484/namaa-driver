import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract final class MapsConfig {
  static const LatLng khartoumCenter = LatLng(15.5007, 32.5599);
  static const double defaultZoom = 15.0;
  static const double navigationZoom = 17.0;
  static const double overviewZoom = 12.0;

  static const double locationAccuracyThresholdMeters = 50.0;
  static const double arrivedAtPickupThresholdMeters = 100.0;
  static const double arrivedAtDestinationThresholdMeters = 100.0;
}
