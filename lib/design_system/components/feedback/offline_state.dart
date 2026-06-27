import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/typography.dart';
import '../../tokens/spacing.dart';
import '../buttons/primary_button.dart';

class OfflineState extends StatelessWidget {
  const OfflineState({super.key, this.onRetry});
  final VoidCallback? onRetry;

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
                color: NamaaColors.offlineGrey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off,
                size: 36,
                color: NamaaColors.offlineGrey,
              ),
            ),
            const SizedBox(height: NamaaSpacing.md),
            Text('لا يوجد اتصال', style: NamaaTypography.heading3),
            const SizedBox(height: NamaaSpacing.sm),
            Text(
              'تحقق من اتصالك بالإنترنت وأعد المحاولة',
              style: NamaaTypography.bodyMedium.copyWith(
                color: NamaaColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: NamaaSpacing.lg),
              PrimaryButton(label: 'إعادة المحاولة', onPressed: onRetry, fullWidth: false),
            ],
          ],
        ),
      ),
    );
  }
}
