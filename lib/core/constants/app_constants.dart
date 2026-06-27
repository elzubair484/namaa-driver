abstract final class AppConstants {
  static const String appName = 'نماء للسائقين';
  static const String appNameEn = 'Namaa Driver';
  static const String defaultCountryCode = 'SD';
  static const String defaultLocale = 'ar';

  static const List<String> supportedLocales = ['ar', 'en'];

  static const int maxDocumentFileSizeMb = 10;
  static const int maxAvatarFileSizeMb = 5;
  static const int tripHistoryPageSize = 20;
  static const int transactionPageSize = 20;
  static const int notificationPageSize = 30;

  static const double minWithdrawalAmount = 100.0;
  static const double maxWithdrawalAmount = 50000.0;
}
