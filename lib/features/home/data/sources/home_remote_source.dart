import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/error/app_exception.dart';
import '../../../auth/domain/entities/driver_entity.dart';
import '../../domain/entities/earnings_entity.dart';

class HomeRemoteSource {
  HomeRemoteSource(this._client);
  final SupabaseClient _client;

  Future<void> setOnlineStatus({
    required String driverId,
    required bool isOnline,
  }) async {
    try {
      await _client.from(SupabaseConfig.driversTable).update({
        'is_online': isOnline,
        'last_seen_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', driverId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, code: e.code);
    }
  }

  Future<void> updateLocation({
    required String driverId,
    required double lat,
    required double lng,
  }) async {
    try {
      // PostGIS requires WKT format for GEOMETRY columns
      final wkt = 'POINT($lng $lat)';
      await _client.from(SupabaseConfig.driversTable).update({
        'last_location': wkt,
        'last_seen_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', driverId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, code: e.code);
    }
  }

  Future<EarningsEntity> getTodayEarnings(String driverId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day)
          .toUtc()
          .toIso8601String();
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59)
          .toUtc()
          .toIso8601String();

      final data = await _client
          .from('trips')
          .select('fare_amount')
          .eq('driver_id', driverId)
          .eq('status', 'completed')
          .gte('completed_at', startOfDay)
          .lte('completed_at', endOfDay);

      final trips = data as List;
      final total = trips.fold<double>(
        0,
        (sum, row) => sum + ((row['fare_amount'] as num?)?.toDouble() ?? 0),
      );

      return EarningsEntity(
        totalEarnings: total,
        tripsCount: trips.length,
        period: 'اليوم',
      );
    } on PostgrestException catch (e) {
      throw ServerException(e.message, code: e.code);
    }
  }

  Stream<DriverEntity?> watchDriverStatus(String userId) {
    return _client
        .from(SupabaseConfig.driversTable)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((rows) {
          if (rows.isEmpty) return null;
          final row = rows.first;
          return DriverEntity(
            id: row['id'] as String,
            userId: row['user_id'] as String,
            fullName: row['full_name'] as String,
            phone: row['phone'] as String,
            email: row['email'] as String?,
            avatarUrl: row['avatar_url'] as String?,
            status: _parseStatus(row['status'] as String?),
            rating: (row['rating'] as num?)?.toDouble() ?? 5.0,
            totalTrips: (row['total_trips'] as int?) ?? 0,
            isOnline: (row['is_online'] as bool?) ?? false,
            createdAt: DateTime.tryParse(
                    row['created_at'] as String? ?? '') ??
                DateTime.now(),
          );
        });
  }

  DriverStatus _parseStatus(String? s) => switch (s) {
        'under_review' => DriverStatus.underReview,
        'approved' => DriverStatus.approved,
        'rejected' => DriverStatus.rejected,
        'suspended' => DriverStatus.suspended,
        'inactive' => DriverStatus.inactive,
        _ => DriverStatus.pending,
      };
}
