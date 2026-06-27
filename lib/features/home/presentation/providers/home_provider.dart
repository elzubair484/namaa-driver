import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/services/driver_location_service.dart';
import '../../../auth/domain/entities/driver_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/sources/home_remote_source.dart';
import '../../domain/entities/earnings_entity.dart';

// ── Remote source ──────────────────────────────────────────────

final homeRemoteSourceProvider = Provider<HomeRemoteSource>((ref) {
  return HomeRemoteSource(ref.watch(supabaseClientProvider));
});

// ── Driver location service ────────────────────────────────────

final driverLocationServiceProvider = Provider<DriverLocationService>((ref) {
  return DriverLocationService(ref.watch(locationServiceProvider));
});

// ── Live driver stream ─────────────────────────────────────────

final liveDriverProvider = StreamProvider<DriverEntity?>((ref) {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return Stream.value(null);
  return ref.watch(homeRemoteSourceProvider).watchDriverStatus(user.id);
});

// ── Online/offline toggle ──────────────────────────────────────

class DriverStatusNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final driver = ref.watch(liveDriverProvider).valueOrNull;
    return driver?.isOnline ?? false;
  }

  Future<void> toggle() async {
    final current = state.valueOrNull ?? false;
    final driver = ref.read(currentDriverProvider).valueOrNull;
    if (driver == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final next = !current;
      await ref
          .read(homeRemoteSourceProvider)
          .setOnlineStatus(driverId: driver.id, isOnline: next);

      if (next) {
        // Start broadcasting location while online
        await ref
            .read(driverLocationServiceProvider)
            .start((lat, lng) async {
          await ref.read(homeRemoteSourceProvider).updateLocation(
                driverId: driver.id,
                lat: lat,
                lng: lng,
              );
        });
      } else {
        ref.read(driverLocationServiceProvider).stop();
      }

      return next;
    });
  }
}

final driverStatusProvider =
    AsyncNotifierProvider<DriverStatusNotifier, bool>(DriverStatusNotifier.new);

// ── Today's earnings ───────────────────────────────────────────

final todayEarningsProvider = FutureProvider<EarningsEntity>((ref) async {
  final driver = ref.watch(currentDriverProvider).valueOrNull;
  if (driver == null) {
    return const EarningsEntity(totalEarnings: 0, tripsCount: 0, period: 'اليوم');
  }
  return ref.read(homeRemoteSourceProvider).getTodayEarnings(driver.id);
});
