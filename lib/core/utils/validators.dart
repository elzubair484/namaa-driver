abstract final class Validators {
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'أدخل رقم الهاتف';
    if (!RegExp(r'^\+?[0-9]{9,15}$').hasMatch(value.trim())) {
      return 'رقم الهاتف غير صحيح';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'أدخل الاسم';
    if (value.trim().length < 2) return 'الاسم قصير جداً';
    if (value.trim().length > 100) return 'الاسم طويل جداً';
    return null;
  }

  static String? required(String? value, {String label = 'هذا الحقل'}) {
    if (value == null || value.trim().isEmpty) return '$label مطلوب';
    return null;
  }

  static String? vehicleYear(String? value) {
    if (value == null || value.trim().isEmpty) return 'أدخل سنة الصنع';
    final year = int.tryParse(value.trim());
    if (year == null) return 'سنة غير صحيحة';
    final currentYear = DateTime.now().year;
    if (year < 2000 || year > currentYear + 1) {
      return 'السنة يجب أن تكون بين 2000 و$currentYear';
    }
    return null;
  }

  static String? plateNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'أدخل رقم اللوحة';
    if (value.trim().length < 3) return 'رقم اللوحة قصير جداً';
    return null;
  }

  static String? amount(String? value, {double min = 0, double? max}) {
    if (value == null || value.trim().isEmpty) return 'أدخل المبلغ';
    final amount = double.tryParse(value.trim());
    if (amount == null) return 'مبلغ غير صحيح';
    if (amount < min) return 'المبلغ يجب أن يكون على الأقل $min';
    if (max != null && amount > max) return 'المبلغ يجب ألا يتجاوز $max';
    return null;
  }
}
