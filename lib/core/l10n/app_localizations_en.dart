// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Namaa Driver';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get onTrip => 'On Trip';

  @override
  String get pending => 'Pending';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get submit => 'Submit';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get done => 'Done';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get phoneEntry => 'Enter your phone number';

  @override
  String get phoneEntryHint => '9XXXXXXXXX';

  @override
  String get phoneEntryLabel => 'Phone Number';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get otpVerification => 'Verify OTP';

  @override
  String otpSentTo(String phone) {
    return 'Code sent to $phone';
  }

  @override
  String get resendOtp => 'Resend Code';

  @override
  String resendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get verifyOtp => 'Verify';

  @override
  String get homeTitle => 'Home';

  @override
  String get todayEarnings => 'Today\'s Earnings';

  @override
  String get todayTrips => 'Today\'s Trips';

  @override
  String get earnings => 'Earnings';

  @override
  String get wallet => 'Wallet';

  @override
  String get history => 'History';

  @override
  String get notifications => 'Notifications';

  @override
  String get profile => 'Profile';

  @override
  String get tripRequest => 'New Trip Request';

  @override
  String get acceptTrip => 'Accept';

  @override
  String get rejectTrip => 'Reject';

  @override
  String get pickupLocation => 'Pickup Location';

  @override
  String get destination => 'Destination';

  @override
  String get estimatedFare => 'Estimated Fare';

  @override
  String get distance => 'Distance';

  @override
  String get pendingApproval => 'Application Under Review';

  @override
  String get pendingApprovalMessage =>
      'Your documents are being reviewed. We will notify you once approved.';

  @override
  String get noConnection => 'No Connection';

  @override
  String get noConnectionMessage =>
      'Check your internet connection and try again';

  @override
  String get balance => 'Balance';

  @override
  String get totalEarned => 'Total Earned';

  @override
  String get totalTrips => 'Total Trips';

  @override
  String get rating => 'Rating';

  @override
  String get acceptanceRate => 'Acceptance Rate';

  @override
  String get completionRate => 'Completion Rate';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get currency => 'SDG';
}
