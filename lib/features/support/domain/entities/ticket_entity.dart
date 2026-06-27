import 'package:equatable/equatable.dart';

enum TicketCategory {
  tripIssue,
  paymentIssue,
  accountIssue,
  technical,
  other;

  String get dbValue => switch (this) {
        TicketCategory.tripIssue => 'trip_issue',
        TicketCategory.paymentIssue => 'payment_issue',
        TicketCategory.accountIssue => 'account_issue',
        TicketCategory.technical => 'technical',
        TicketCategory.other => 'other',
      };

  String get labelAr => switch (this) {
        TicketCategory.tripIssue => 'مشكلة رحلة',
        TicketCategory.paymentIssue => 'مشكلة دفع',
        TicketCategory.accountIssue => 'مشكلة حساب',
        TicketCategory.technical => 'مشكلة تقنية',
        TicketCategory.other => 'أخرى',
      };

  static TicketCategory fromDb(String? s) => switch (s) {
        'trip_issue' => TicketCategory.tripIssue,
        'payment_issue' => TicketCategory.paymentIssue,
        'account_issue' => TicketCategory.accountIssue,
        'technical' => TicketCategory.technical,
        _ => TicketCategory.other,
      };
}

enum TicketStatus {
  open,
  inProgress,
  resolved,
  closed;

  String get labelAr => switch (this) {
        TicketStatus.open => 'مفتوحة',
        TicketStatus.inProgress => 'قيد المعالجة',
        TicketStatus.resolved => 'محلولة',
        TicketStatus.closed => 'مغلقة',
      };

  static TicketStatus fromDb(String? s) => switch (s) {
        'in_progress' => TicketStatus.inProgress,
        'resolved' => TicketStatus.resolved,
        'closed' => TicketStatus.closed,
        _ => TicketStatus.open,
      };
}

class TicketEntity extends Equatable {
  const TicketEntity({
    required this.id,
    required this.category,
    required this.subject,
    required this.status,
    required this.createdAt,
    this.tripId,
    this.resolvedAt,
  });

  final String id;
  final TicketCategory category;
  final String subject;
  final TicketStatus status;
  final DateTime createdAt;
  final String? tripId;
  final DateTime? resolvedAt;

  @override
  List<Object?> get props => [id, status];
}

class MessageEntity extends Equatable {
  const MessageEntity({
    required this.id,
    required this.ticketId,
    required this.senderId,
    required this.senderType,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final String ticketId;
  final String senderId;
  final String senderType; // 'driver' | 'admin'
  final String message;
  final DateTime createdAt;

  bool get isDriver => senderType == 'driver';

  @override
  List<Object?> get props => [id];
}
