// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'نماء للسائقين';

  @override
  String get online => 'متصل';

  @override
  String get offline => 'غير متصل';

  @override
  String get onTrip => 'في رحلة';

  @override
  String get pending => 'قيد المراجعة';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get save => 'حفظ';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get submit => 'إرسال';

  @override
  String get next => 'التالي';

  @override
  String get back => 'رجوع';

  @override
  String get done => 'تم';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get ok => 'حسناً';

  @override
  String get error => 'خطأ';

  @override
  String get success => 'تم بنجاح';

  @override
  String get phoneEntry => 'أدخل رقم هاتفك';

  @override
  String get phoneEntryHint => '9XXXXXXXXX';

  @override
  String get phoneEntryLabel => 'رقم الهاتف';

  @override
  String get sendOtp => 'إرسال الرمز';

  @override
  String get otpVerification => 'التحقق من الرمز';

  @override
  String otpSentTo(String phone) {
    return 'تم إرسال الرمز إلى $phone';
  }

  @override
  String get resendOtp => 'إعادة إرسال الرمز';

  @override
  String resendIn(int seconds) {
    return 'إعادة الإرسال بعد $seconds ثانية';
  }

  @override
  String get verifyOtp => 'تحقق';

  @override
  String get homeTitle => 'الرئيسية';

  @override
  String get todayEarnings => 'أرباح اليوم';

  @override
  String get todayTrips => 'رحلات اليوم';

  @override
  String get earnings => 'الأرباح';

  @override
  String get wallet => 'المحفظة';

  @override
  String get history => 'الرحلات';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get profile => 'حسابي';

  @override
  String get tripRequest => 'طلب رحلة جديد';

  @override
  String get acceptTrip => 'قبول';

  @override
  String get rejectTrip => 'رفض';

  @override
  String get pickupLocation => 'نقطة الالتقاء';

  @override
  String get destination => 'الوجهة';

  @override
  String get estimatedFare => 'الأجرة التقديرية';

  @override
  String get distance => 'المسافة';

  @override
  String get pendingApproval => 'طلبك قيد المراجعة';

  @override
  String get pendingApprovalMessage =>
      'وثائقك قيد المراجعة. سنخبرك فور الموافقة عليها.';

  @override
  String get noConnection => 'لا يوجد اتصال';

  @override
  String get noConnectionMessage => 'تحقق من اتصالك بالإنترنت وأعد المحاولة';

  @override
  String get balance => 'الرصيد';

  @override
  String get totalEarned => 'إجمالي الأرباح';

  @override
  String get totalTrips => 'إجمالي الرحلات';

  @override
  String get rating => 'التقييم';

  @override
  String get acceptanceRate => 'معدل القبول';

  @override
  String get completionRate => 'معدل الإكمال';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirm => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get currency => 'ج.س';
}
