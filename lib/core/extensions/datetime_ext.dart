import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  String toArabicDate() {
    return DateFormat('d MMMM yyyy', 'ar').format(toLocal());
  }

  String toArabicTime() {
    return DateFormat('hh:mm a', 'ar').format(toLocal());
  }

  String toArabicDateTime() {
    return DateFormat('d/M/yyyy - hh:mm a', 'ar').format(toLocal());
  }

  String toShortDate() {
    return DateFormat('d/M/yyyy').format(toLocal());
  }

  String toRelative() {
    final now = DateTime.now();
    final diff = now.difference(toLocal());

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    return toShortDate();
  }

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return isAfter(weekStart.subtract(const Duration(days: 1)));
  }

  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }
}
