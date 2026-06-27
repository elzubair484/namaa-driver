enum AppEnvironment { development, staging, production }

class AppConfig {
  const AppConfig._({
    required this.environment,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.googleMapsApiKey,
  });

  final AppEnvironment environment;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String googleMapsApiKey;

  static AppConfig? _instance;

  static AppConfig get instance {
    assert(_instance != null, 'AppConfig must be initialized before use');
    return _instance!;
  }

  static void initialize({
    required AppEnvironment environment,
    required String supabaseUrl,
    required String supabaseAnonKey,
    required String googleMapsApiKey,
  }) {
    _instance = AppConfig._(
      environment: environment,
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
      googleMapsApiKey: googleMapsApiKey,
    );
  }

  bool get isDevelopment => environment == AppEnvironment.development;
  bool get isProduction => environment == AppEnvironment.production;

  static const locationUpdateIntervalSeconds = 3;
  static const tripRequestTimeoutSeconds = 30;
  static const otpResendCooldownSeconds = 60;
}
