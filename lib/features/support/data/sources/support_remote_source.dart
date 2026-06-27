import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/app_exception.dart';
import '../../domain/entities/ticket_entity.dart';

class SupportRemoteSource {
  SupportRemoteSource(this._client);
  final SupabaseClient _client;

  Future<List<TicketEntity>> getTickets(String driverId) async {
    try {
      final data = await _client
          .from('support_tickets')
          .select()
          .eq('driver_id', driverId)
          .order('created_at', ascending: false);
      return (data as List)
          .map((r) => _ticketFromJson(r as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message, code: e.code);
    }
  }

  Future<TicketEntity> createTicket({
    required String driverId,
    required TicketCategory category,
    required String subject,
    required String firstMessage,
    String? tripId,
  }) async {
    try {
      final ticketData = await _client
          .from('support_tickets')
          .insert({
            'driver_id': driverId,
            'category': category.dbValue,
            'subject': subject,
            if (tripId != null) 'trip_id': tripId,
          })
          .select()
          .single();

      final ticket = _ticketFromJson(ticketData);

      // Insert first message
      await _client.from('support_messages').insert({
        'ticket_id': ticket.id,
        'sender_id': driverId,
        'sender_type': 'driver',
        'message': firstMessage,
      });

      return ticket;
    } on PostgrestException catch (e) {
      throw ServerException(e.message, code: e.code);
    }
  }

  Stream<List<MessageEntity>> watchMessages(String ticketId) {
    return _client
        .from('support_messages')
        .stream(primaryKey: ['id'])
        .eq('ticket_id', ticketId)
        .order('created_at')
        .map((rows) => rows.map(_messageFromJson).toList());
  }

  Future<void> sendMessage({
    required String ticketId,
    required String senderId,
    required String message,
  }) async {
    try {
      await _client.from('support_messages').insert({
        'ticket_id': ticketId,
        'sender_id': senderId,
        'sender_type': 'driver',
        'message': message,
      });
    } on PostgrestException catch (e) {
      throw ServerException(e.message, code: e.code);
    }
  }

  TicketEntity _ticketFromJson(Map<String, dynamic> j) => TicketEntity(
        id: j['id'] as String,
        category: TicketCategory.fromDb(j['category'] as String?),
        subject: j['subject'] as String? ?? '',
        status: TicketStatus.fromDb(j['status'] as String?),
        createdAt:
            DateTime.tryParse(j['created_at'] as String? ?? '') ?? DateTime.now(),
        tripId: j['trip_id'] as String?,
        resolvedAt: DateTime.tryParse(j['resolved_at'] as String? ?? ''),
      );

  MessageEntity _messageFromJson(Map<String, dynamic> j) => MessageEntity(
        id: j['id'] as String,
        ticketId: j['ticket_id'] as String,
        senderId: j['sender_id'] as String,
        senderType: j['sender_type'] as String? ?? 'driver',
        message: j['message'] as String? ?? '',
        createdAt:
            DateTime.tryParse(j['created_at'] as String? ?? '') ?? DateTime.now(),
      );
}
