import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../trips/domain/entities/trip_entity.dart';
import '../../data/sources/history_remote_source.dart';

final historyRemoteSourceProvider = Provider<HistoryRemoteSource>((ref) {
  return HistoryRemoteSource(ref.watch(supabaseClientProvider));
});

// Paginated trip list state
class TripHistoryState {
  const TripHistoryState({
    this.trips = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.page = 0,
    this.error,
    this.statusFilter,
  });

  final List<TripEntity> trips;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final String? error;
  final TripStatus? statusFilter;

  TripHistoryState copyWith({
    List<TripEntity>? trips,
    bool? isLoading,
    bool? hasMore,
    int? page,
    String? error,
    TripStatus? statusFilter,
    bool clearError = false,
  }) =>
      TripHistoryState(
        trips: trips ?? this.trips,
        isLoading: isLoading ?? this.isLoading,
        hasMore: hasMore ?? this.hasMore,
        page: page ?? this.page,
        error: clearError ? null : error ?? this.error,
        statusFilter: statusFilter ?? this.statusFilter,
      );
}

class TripHistoryNotifier extends AutoDisposeNotifier<TripHistoryState> {
  @override
  TripHistoryState build() {
    Future.microtask(loadMore);
    return const TripHistoryState(isLoading: true);
  }

  Future<void> loadMore() async {
    if (state.isLoading && state.page > 0) return;
    if (!state.hasMore) return;

    final driver = ref.read(currentDriverProvider).valueOrNull;
    if (driver == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final newTrips = await ref
          .read(historyRemoteSourceProvider)
          .getTrips(driver.id,
              page: state.page, statusFilter: state.statusFilter);

      state = state.copyWith(
        trips: [...state.trips, ...newTrips],
        isLoading: false,
        hasMore: newTrips.length == 20,
        page: state.page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFilter(TripStatus? status) {
    state = TripHistoryState(
      isLoading: true,
      statusFilter: status,
    );
    loadMore();
  }

  Future<void> refresh() async {
    state = TripHistoryState(
      isLoading: true,
      statusFilter: state.statusFilter,
    );
    await loadMore();
  }
}

final tripHistoryProvider =
    AutoDisposeNotifierProvider<TripHistoryNotifier, TripHistoryState>(
        TripHistoryNotifier.new);

// Single trip detail
final tripDetailProvider =
    FutureProvider.autoDispose.family<TripEntity?, String>((ref, id) async {
  final driver = ref.watch(currentDriverProvider).valueOrNull;
  if (driver == null) return null;
  return ref.read(historyRemoteSourceProvider).getTripById(id);
});

// Performance stats
final performanceProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final driver = ref.watch(currentDriverProvider).valueOrNull;
  if (driver == null) return {};
  return ref
      .read(historyRemoteSourceProvider)
      .getPerformanceStats(driver.id);
});
