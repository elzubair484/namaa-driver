import 'dart:async';
import '../config/app_config.dart';
import '../error/app_exception.dart';
import 'location_service.dart';

typedef LocationCallback = Future<void> Function(double lat, double lng);

class DriverLocationService {
  DriverLocationService(this._locationService);
  final LocationService _locationService;

  Timer? _timer;
  bool _running = false;

  bool get isRunning => _running;

  Future<void> start(LocationCallback onLocation) async {
    if (_running) return;
    _running = true;

    // Push immediately on start
    await _push(onLocation);

    final interval = Duration(
      seconds: AppConfig.locationUpdateIntervalSeconds,
    );
    _timer = Timer.periodic(interval, (_) => _push(onLocation));
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _running = false;
  }

  Future<void> _push(LocationCallback onLocation) async {
    try {
      final pos = await _locationService.getCurrentPosition();
      await onLocation(pos.latitude, pos.longitude);
    } on PermissionException {
      stop();
    } on LocationException {
      // Service disabled — stop and let the UI surface the error
      stop();
    } catch (_) {
      // Network/server errors are transient — keep timer running
    }
  }
}
