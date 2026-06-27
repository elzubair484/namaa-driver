import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../tokens/colors.dart';
import '../../tokens/typography.dart';
import '../../tokens/radius.dart';

class NamaaPhoneField extends StatelessWidget {
  const NamaaPhoneField({
    super.key,
    this.controller,
    this.onChanged,
    this.onCountryChanged,
    this.label,
    this.hint,
    this.initialCountryCode = 'SD',
    this.focusNode,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final Function(dynamic)? onCountryChanged;
  final String? label;
  final String? hint;
  final String initialCountryCode;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: NamaaTypography.labelMedium),
          const SizedBox(height: 6),
        ],
        IntlPhoneField(
          controller: controller,
          focusNode: focusNode,
          initialCountryCode: initialCountryCode,
          onChanged: (phone) => onChanged?.call(phone.completeNumber),
          onCountryChanged: onCountryChanged,
          keyboardType: TextInputType.phone,
          style: NamaaTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: hint ?? '9XXXXXXXXX',
            hintStyle: NamaaTypography.bodyMedium.copyWith(
              color: NamaaColors.textHint,
            ),
            border: OutlineInputBorder(
              borderRadius: NamaaRadius.mdAll,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: NamaaRadius.mdAll,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: NamaaRadius.mdAll,
              borderSide: const BorderSide(color: NamaaColors.primary, width: 2),
            ),
            filled: true,
            fillColor: NamaaColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
