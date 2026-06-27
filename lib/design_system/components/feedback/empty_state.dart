import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/typography.dart';
import '../../tokens/spacing.dart';
import '../buttons/primary_button.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NamaaSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: NamaaColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: NamaaColors.textHint),
              ),
              const SizedBox(height: NamaaSpacing.md),
            ],
            Text(title, style: NamaaTypography.heading3, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: NamaaSpacing.sm),
              Text(
                message!,
                style: NamaaTypography.bodyMedium.copyWith(
                  color: NamaaColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: NamaaSpacing.lg),
              PrimaryButton(label: actionLabel!, onPressed: onAction, fullWidth: false),
            ],
          ],
        ),
      ),
    );
  }
}
