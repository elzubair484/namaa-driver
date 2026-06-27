import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/typography.dart';
import '../../tokens/spacing.dart';
import '../buttons/primary_button.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.title = 'حدث خطأ',
    this.message,
    this.onRetry,
    this.retryLabel = 'إعادة المحاولة',
  });

  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NamaaSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: NamaaColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 36,
                color: NamaaColors.error,
              ),
            ),
            const SizedBox(height: NamaaSpacing.md),
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
            if (onRetry != null) ...[
              const SizedBox(height: NamaaSpacing.lg),
              PrimaryButton(label: retryLabel, onPressed: onRetry, fullWidth: false),
            ],
          ],
        ),
      ),
    );
  }
}
