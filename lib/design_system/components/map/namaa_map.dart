import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NamaaMap extends StatefulWidget {
  const NamaaMap({
    super.key,
    this.initialPosition,
    this.onMapCreated,
    this.markers,
    this.polylines,
    this.circles,
    this.onTap,
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = false,
    this.zoomControlsEnabled = false,
    this.compassEnabled = false,
    this.mapType = MapType.normal,
  });

  final LatLng? initialPosition;
  final MapCreatedCallback? onMapCreated;
  final Set<Marker>? markers;
  final Set<Polyline>? polylines;
  final Set<Circle>? circles;
  final ArgumentCallback<LatLng>? onTap;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final bool zoomControlsEnabled;
  final bool compassEnabled;
  final MapType mapType;

  @override
  State<NamaaMap> createState() => _NamaaMapState();
}

class _NamaaMapState extends State<NamaaMap> {
  static const LatLng _khartoumDefault = LatLng(15.5007, 32.5599);

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.initialPosition ?? _khartoumDefault,
        zoom: 15,
      ),
      onMapCreated: widget.onMapCreated,
      markers: widget.markers ?? {},
      polylines: widget.polylines ?? {},
      circles: widget.circles ?? {},
      onTap: widget.onTap,
      myLocationEnabled: widget.myLocationEnabled,
      myLocationButtonEnabled: widget.myLocationButtonEnabled,
      zoomControlsEnabled: widget.zoomControlsEnabled,
      compassEnabled: widget.compassEnabled,
      mapType: widget.mapType,
      buildingsEnabled: true,
      trafficEnabled: false,
      liteModeEnabled: false,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: false,
      zoomGesturesEnabled: true,
    );
  }
}
