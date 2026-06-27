import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../tokens/colors.dart';

class RoutePolylineBuilder {
  static Polyline build({
    required String id,
    required List<LatLng> points,
    Color color = NamaaColors.primary,
    double width = 5,
  }) {
    return Polyline(
      polylineId: PolylineId(id),
      points: points,
      color: color,
      width: width.toInt(),
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
    );
  }
}
