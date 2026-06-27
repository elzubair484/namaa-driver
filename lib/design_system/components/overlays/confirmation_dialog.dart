import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/typography.dart';
import '../../tokens/spacing.dart';
import '../../tokens/radius.dart';
import '../buttons/primary_button.dart';
import '../buttons/secondary_button.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'تأكيد',
    this.cancelLabel = 'إلغاء',
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.icon,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final IconData? icon;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'تأكيد',
    String cancelLabel = 'إلغاء',
    bool isDestructive = false,
    IconData? icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        icon: icon,
        onConfirm: () => Navigator.of(ctx).pop(true),
        onCancel: () => Navigator.of(ctx).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: NamaaRadius.lgAll),
      contentPadding: const EdgeInsets.all(NamaaSpacing.lg),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: (isDestructive ? NamaaColors.error : NamaaColors.primary)
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDestructive ? NamaaColors.error : NamaaColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: NamaaSpacing.md),
          ],
          Text(title, style: NamaaTypography.heading3, textAlign: TextAlign.center),
          const SizedBox(height: NamaaSpacing.sm),
          Text(
            message,
            style: NamaaTypography.bodyMedium.copyWith(
              color: NamaaColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: NamaaSpacing.lg),
          PrimaryButton(
            label: confirmLabel,
            onPressed: onConfirm,
          ),
          const SizedBox(height: NamaaSpacing.sm),
          SecondaryButton(
            label: cancelLabel,
            onPressed: onCancel ?? () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
