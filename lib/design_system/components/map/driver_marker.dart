import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverMarkerBuilder {
  static Future<BitmapDescriptor> build({
    bool isOnline = true,
  }) async {
    return BitmapDescriptor.defaultMarkerWithHue(
      isOnline
          ? BitmapDescriptor.hueGreen
          : BitmapDescriptor.hueAzure,
    );
  }
}
