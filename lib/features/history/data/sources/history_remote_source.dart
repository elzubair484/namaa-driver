import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/app_exception.dart';
import '../../../trips/data/models/trip_model.dart';
import '../../../trips/domain/entities/trip_entity.dart';

class HistoryRemoteSource {
  HistoryRemoteSource(this._client);
  final SupabaseClient _client;

  static const _pageSize = 20;

  Future<List<TripEntity>> getTrips(
    String driverId, {
    int page = 0,
    TripStatus? statusFilter,
  }) async {
    try {
      var builder = _client
          .from('trips')
          .select()
          .eq('driver_id', driverId);

      if (statusFilter != null) {
        builder = builder.eq('status', statusFilter.dbValue);
      }

      final data = await builder
          .order('requested_at', ascending: false)
          .range(page * _pageSize, (page + 1) * _pageSize - 1);

      return (data as List).map((r) => TripModel.fromJson(r)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message, code: e.code);
    }
  }

  Future<TripEntity?> getTripById(String tripId) async {
    try {
      final data = await _client
          .from('trips')
          .select()
          .eq('id', tripId)
          .maybeSingle();
      if (data == null) return null;
      return TripModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, code: e.code);
    }
  }

  Future<Map<String, dynamic>> getPerformanceStats(String driverId) async {
    try {
      final driverData = await _client
          .from('drivers')
          .select(
              'rating, total_trips, acceptance_rate, completion_rate, created_at')
          .eq('id', driverId)
          .single();

      // Monthly trip counts for the last 6 months
      final now = DateTime.now();
      final sixMonthsAgo =
          DateTime(now.year, now.month - 5, 1).toUtc().toIso8601String();

      final tripData = await _client
          .from('trips')
          .select('completed_at, driver_earnings, passenger_rating')
          .eq('driver_id', driverId)
          .eq('status', 'completed')
          .gte('completed_at', sixMonthsAgo);

      return {
        'driver': driverData,
        'trips': tripData,
      };
    } on PostgrestException catch (e) {
      throw ServerException(e.message, code: e.code);
    }
  }
}
