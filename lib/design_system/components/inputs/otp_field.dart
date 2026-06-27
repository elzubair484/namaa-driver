import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../tokens/colors.dart';
import '../../tokens/typography.dart';
import '../../tokens/radius.dart';

class OtpField extends StatelessWidget {
  const OtpField({
    super.key,
    required this.onCompleted,
    this.onChanged,
    this.length = 6,
    this.controller,
    this.autoFocus = true,
  });

  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final int length;
  final TextEditingController? controller;
  final bool autoFocus;

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      length: length,
      controller: controller,
      autoFocus: autoFocus,
      animationType: AnimationType.fade,
      keyboardType: TextInputType.number,
      textStyle: NamaaTypography.heading2,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: NamaaRadius.mdAll,
        fieldHeight: 56,
        fieldWidth: 48,
        activeColor: NamaaColors.primary,
        inactiveColor: NamaaColors.divider,
        selectedColor: NamaaColors.primary,
        activeFillColor: NamaaColors.surface,
        inactiveFillColor: NamaaColors.surface,
        selectedFillColor: NamaaColors.primaryLight,
        errorBorderColor: NamaaColors.error,
      ),
      enableActiveFill: true,
      onCompleted: onCompleted,
      onChanged: onChanged ?? (_) {},
    );
  }
}
