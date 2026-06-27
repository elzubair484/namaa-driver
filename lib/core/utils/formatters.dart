import 'package:intl/intl.dart';

abstract final class Formatters {
  static final _sdgFormat = NumberFormat('#,##0.00', 'ar');
  static final _compactFormat = NumberFormat.compact(locale: 'ar');

  static String currency(double amount, {String symbol = 'ج.س'}) {
    return '${_sdgFormat.format(amount)} $symbol';
  }

  static String compactCurrency(double amount, {String symbol = 'ج.س'}) {
    return '${_compactFormat.format(amount)} $symbol';
  }

  static String distance(double km) {
    if (km < 1) {
      return '${(km * 1000).toInt()} م';
    }
    return '${km.toStringAsFixed(1)} كم';
  }

  static String duration(int minutes) {
    if (minutes < 60) return '$minutes دقيقة';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (m == 0) return '$h ساعة';
    return '$h ساعة و$m دقيقة';
  }

  static String phone(String phone) {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.length == 10) {
      return '${clean.substring(0, 3)} ${clean.substring(3, 6)} ${clean.substring(6)}';
    }
    return phone;
  }

  static String percentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  static String rating(double value) {
    return value.toStringAsFixed(1);
  }
}
