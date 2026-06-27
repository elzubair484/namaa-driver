import 'package:equatable/equatable.dart';

enum NotificationType {
  tripRequest,
  tripUpdate,
  payment,
  document,
  system,
  support;

  static NotificationType fromDb(String? s) => switch (s) {
        'trip_request' => NotificationType.tripRequest,
        'trip_update' => NotificationType.tripUpdate,
        'payment' => NotificationType.payment,
        'document' => NotificationType.document,
        'support' => NotificationType.support,
        _ => NotificationType.system,
      };
}

class NotificationEntity extends Equatable {
  const NotificationEntity({
    required this.id,
    required this.type,
    required this.titleAr,
    required this.bodyAr,
    required this.isRead,
    required this.createdAt,
    this.data,
    this.readAt,
  });

  final String id;
  final NotificationType type;
  final String titleAr;
  final String bodyAr;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;
  final DateTime? readAt;

  @override
  List<Object?> get props => [id, isRead];
}
