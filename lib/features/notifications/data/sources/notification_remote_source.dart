import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/app_exception.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationRemoteSource {
  NotificationRemoteSource(this._client);
  final SupabaseClient _client;

  Stream<List<NotificationEntity>> watchNotifications(String driverId) {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('recipient_id', driverId)
        .order('created_at', ascending: false)
        .limit(50)
        .map((rows) => rows.map(_fromJson).toList());
  }

  Future<int> getUnreadCount(String driverId) async {
    try {
      final data = await _client
          .from('notifications')
          .select('id')
          .eq('recipient_id', driverId)
          .eq('is_read', false);
      return (data as List).length;
    } on PostgrestException catch (e) {
      throw ServerException(e.message, code: e.code);
    }
  }

  Future<void> markRead(String notificationId) async {
    try {
      await _client.from('notifications').update({
        'is_read': true,
        'read_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', notificationId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, code: e.code);
    }
  }

  Future<void> markAllRead(String driverId) async {
    try {
      await _client
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('recipient_id', driverId)
          .eq('is_read', false);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, code: e.code);
    }
  }

  NotificationEntity _fromJson(Map<String, dynamic> j) => NotificationEntity(
        id: j['id'] as String,
        type: NotificationType.fromDb(j['type'] as String?),
        titleAr: j['title_ar'] as String? ?? '',
        bodyAr: j['body_ar'] as String? ?? '',
        isRead: (j['is_read'] as bool?) ?? false,
        createdAt:
            DateTime.tryParse(j['created_at'] as String? ?? '') ?? DateTime.now(),
        data: j['data'] as Map<String, dynamic>?,
        readAt: DateTime.tryParse(j['read_at'] as String? ?? ''),
      );
}
