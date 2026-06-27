import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/app_exception.dart';
import '../../domain/entities/trip_entity.dart';
import '../models/trip_model.dart';

class TripRemoteSource {
  TripRemoteSource(this._client);
  final SupabaseClient _client;

  /// Stream of the single active/requested trip for this driver.
  Stream<TripEntity?> watchActiveTrip(String driverId) {
    return _client
        .from('trips')
        .stream(primaryKey: ['id'])
        .eq('driver_id', driverId)
        .order('requested_at', ascending: false)
        .limit(1)
        .map((rows) {
          if (rows.isEmpty) return null;
          final trip = TripModel.fromJson(rows.first);
          // Only surface trips that are not yet cancelled/completed
          if (trip.status == TripStatus.cancelled ||
              trip.status == TripStatus.completed) {
            return null;
          }
          return trip;
        });
  }

  Future<TripEntity> acceptTrip(String tripId) async {
    try {
      final data = await _client
          .from('trips')
          .update({
            'status': TripStatus.driverArriving.dbValue,
            'accepted_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', tripId)
          .select()
          .single();
      return TripModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, code: e.code);
    }
  }

  Future<void> rejectTrip(String tripId) async {
    try {
      await _client.from('trips').update({
        'status': TripStatus.cancelled.dbValue,
        'cancelled_by': 'driver',
        'cancelled_at': DateTime.now().toUtc().toIso8601String(),
        'cancellation_reason': 'رفض السائق',
      }).eq('id', tripId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, code: e.code);
    }
  }

  Future<TripEntity> updateStatus(
    String tripId,
    TripStatus status, {
    Map<String, dynamic>? extra,
  }) async {
    try {
      final payload = <String, dynamic>{'status': status.dbValue};
      if (extra != null) payload.addAll(extra);

      final data = await _client
          .from('trips')
          .update(payload)
          .eq('id', tripId)
          .select()
          .single();
      return TripModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, code: e.code);
    }
  }

  Future<void> ratePassenger(String tripId, int rating) async {
    try {
      await _client
          .from('trips')
          .update({'passenger_rating': rating}).eq('id', tripId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, code: e.code);
    }
  }
}
