abstract final class RouteNames {
  // Auth
  static const String splash = '/';
  static const String phoneEntry = '/phone';
  static const String otpVerification = '/otp';

  // Onboarding
  static const String profileSetup = '/onboarding/profile';
  static const String vehicleInfo = '/onboarding/vehicle';
  static const String documentUpload = '/onboarding/documents';
  static const String pendingApproval = '/onboarding/pending';
  static const String rejectedAccount = '/onboarding/rejected';

  // Main (shell)
  static const String home = '/home';
  static const String earnings = '/earnings';
  static const String history = '/history';
  static const String notifications = '/notifications';
  static const String profile = '/profile';

  // Trip
  static const String navigatingToPassenger = '/trip/navigate';
  static const String passengerPickup = '/trip/pickup';
  static const String activeTrip = '/trip/active';
  static const String tripCompletion = '/trip/complete';
  static const String ratePassenger = '/trip/rate';

  // Wallet
  static const String wallet = '/wallet';
  static const String transactions = '/wallet/transactions';
  static const String withdrawal = '/wallet/withdrawal';

  // History
  static const String tripDetail = '/history/:id';

  // Profile
  static const String editProfile = '/profile/edit';
  static const String vehicleInfoView = '/profile/vehicle';
  static const String documents = '/profile/documents';
  static const String performance = '/profile/performance';

  // Support
  static const String support = '/support';
  static const String ticketDetail = '/support/:id';
}
