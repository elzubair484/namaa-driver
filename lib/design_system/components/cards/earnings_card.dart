import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/typography.dart';
import '../../tokens/spacing.dart';
import '../../tokens/radius.dart';

class EarningsCard extends StatelessWidget {
  const EarningsCard({
    super.key,
    required this.totalEarnings,
    required this.tripsCount,
    required this.period,
    this.onTap,
  });

  final String totalEarnings;
  final int tripsCount;
  final String period;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(NamaaSpacing.md),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [NamaaColors.primary, NamaaColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: NamaaRadius.lgAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  period,
                  style: NamaaTypography.labelMedium.copyWith(
                    color: NamaaColors.onPrimary.withValues(alpha: 0.7),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: NamaaColors.onPrimary.withValues(alpha: 0.7),
                ),
              ],
            ),
            const SizedBox(height: NamaaSpacing.sm),
            Text(
              totalEarnings,
              style: NamaaTypography.displayMedium.copyWith(
                color: NamaaColors.onPrimary,
              ),
            ),
            Text(
              'إجمالي الأرباح',
              style: NamaaTypography.bodySmall.copyWith(
                color: NamaaColors.onPrimary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: NamaaSpacing.md),
            Container(
              height: 1,
              color: NamaaColors.onPrimary.withValues(alpha: 0.2),
            ),
            const SizedBox(height: NamaaSpacing.sm),
            Row(
              children: [
                const Icon(Icons.directions_car, size: 16, color: NamaaColors.onPrimary),
                const SizedBox(width: NamaaSpacing.xs),
                Text(
                  '$tripsCount رحلة',
                  style: NamaaTypography.labelMedium.copyWith(
                    color: NamaaColors.onPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
