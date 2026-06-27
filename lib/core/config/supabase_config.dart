abstract final class SupabaseConfig {
  static const String driversTable = 'drivers';
  static const String vehiclesTable = 'driver_vehicles';
  static const String documentsTable = 'driver_documents';
  static const String tripsTable = 'trips';
  static const String locationsTable = 'driver_locations';
  static const String walletsTable = 'driver_wallets';
  static const String transactionsTable = 'wallet_transactions';
  static const String withdrawalsTable = 'withdrawal_requests';
  static const String notificationsTable = 'notifications';
  static const String ticketsTable = 'support_tickets';
  static const String messagesTable = 'support_messages';

  static const String documentsBucket = 'driver-documents';
  static const String avatarsBucket = 'avatars';

  static String tripsChannel(String driverId) => 'trips:driver_id=eq.$driverId';
  static String notificationsChannel(String driverId) =>
      'notifications:recipient_id=eq.$driverId';
  static String supportChannel(String ticketId) =>
      'support_messages:ticket_id=eq.$ticketId';
}
