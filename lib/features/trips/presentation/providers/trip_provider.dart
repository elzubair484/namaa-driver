import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/sources/trip_remote_source.dart';
import '../../domain/entities/trip_entity.dart';

// ── Remote source ──────────────────────────────────────────────

final tripRemoteSourceProvider = Provider<TripRemoteSource>((ref) {
  return TripRemoteSource(ref.watch(supabaseClientProvider));
});

// ── Active trip stream ─────────────────────────────────────────

final activeTripProvider = StreamProvider<TripEntity?>((ref) {
  final driver = ref.watch(currentDriverProvider).valueOrNull;
  if (driver == null) return Stream.value(null);
  return ref.watch(tripRemoteSourceProvider).watchActiveTrip(driver.id);
});

// ── Trip actions notifier ──────────────────────────────────────

class TripActionsNotifier extends AsyncNotifier<TripEntity?> {
  @override
  Future<TripEntity?> build() async {
    return ref.watch(activeTripProvider).valueOrNull;
  }

  Future<TripEntity?> accept(String tripId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(tripRemoteSourceProvider).acceptTrip(tripId),
    );
    return state.valueOrNull;
  }

  Future<void> reject(String tripId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(tripRemoteSourceProvider).rejectTrip(tripId);
      return null;
    });
  }

  Future<TripEntity?> markArrived(String tripId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(tripRemoteSourceProvider).updateStatus(
            tripId,
            TripStatus.arrived,
            extra: {
              'pickup_arrived_at':
                  DateTime.now().toUtc().toIso8601String(),
            },
          ),
    );
    return state.valueOrNull;
  }

  Future<TripEntity?> startTrip(String tripId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(tripRemoteSourceProvider).updateStatus(
            tripId,
            TripStatus.inProgress,
            extra: {
              'started_at': DateTime.now().toUtc().toIso8601String(),
            },
          ),
    );
    return state.valueOrNull;
  }

  Future<TripEntity?> completeTrip(String tripId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(tripRemoteSourceProvider).updateStatus(
            tripId,
            TripStatus.completed,
            extra: {
              'completed_at': DateTime.now().toUtc().toIso8601String(),
              'payment_status': 'completed',
            },
          ),
    );
    return state.valueOrNull;
  }

  Future<void> ratePassenger(String tripId, int rating) async {
    await ref.read(tripRemoteSourceProvider).ratePassenger(tripId, rating);
    // Reset active trip so home resets
    state = const AsyncData(null);
  }
}

final tripActionsProvider =
    AsyncNotifierProvider<TripActionsNotifier, TripEntity?>(
        TripActionsNotifier.new);
