import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/typography.dart';
import '../../tokens/spacing.dart';
import 'namaa_card.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.trend,
    this.trendPositive,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final String? trend;
  final bool? trendPositive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return NamaaCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (iconColor ?? NamaaColors.primary).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: iconColor ?? NamaaColors.primary,
              ),
            ),
          if (icon != null) const SizedBox(height: NamaaSpacing.sm),
          Text(value, style: NamaaTypography.heading2),
          const SizedBox(height: 2),
          Text(
            label,
            style: NamaaTypography.bodySmall.copyWith(
              color: NamaaColors.textSecondary,
            ),
          ),
          if (trend != null) ...[
            const SizedBox(height: NamaaSpacing.xs),
            Row(
              children: [
                Icon(
                  trendPositive == true
                      ? Icons.trending_up
                      : Icons.trending_down,
                  size: 14,
                  color: trendPositive == true
                      ? NamaaColors.success
                      : NamaaColors.error,
                ),
                const SizedBox(width: 2),
                Text(
                  trend!,
                  style: NamaaTypography.caption.copyWith(
                    color: trendPositive == true
                        ? NamaaColors.success
                        : NamaaColors.error,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
