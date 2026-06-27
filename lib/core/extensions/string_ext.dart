extension StringExt on String {
  bool get isValidPhone {
    return RegExp(r'^\+?[0-9]{9,15}$').hasMatch(replaceAll(' ', ''));
  }

  bool get isValidName {
    return trim().length >= 2;
  }

  String get maskedPhone {
    if (length < 8) return this;
    return '${substring(0, 3)}****${substring(length - 3)}';
  }

  String get firstWord {
    final parts = trim().split(' ');
    return parts.isNotEmpty ? parts.first : this;
  }

  String toArabicNumbers() {
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var result = this;
    for (int i = 0; i < en.length; i++) {
      result = result.replaceAll(en[i], ar[i]);
    }
    return result;
  }
}

extension NullableStringExt on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;
}
