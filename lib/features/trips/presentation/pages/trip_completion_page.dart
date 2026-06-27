import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/components/buttons/primary_button.dart';
import '../../domain/entities/trip_entity.dart';

class TripCompletionPage extends StatelessWidget {
  const TripCompletionPage({super.key, required this.trip});
  final TripEntity trip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NamaaColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(NamaaSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Success icon
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: NamaaColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle,
                      color: NamaaColors.primaryDark, size: 60),
                ),
              ),
              const SizedBox(height: NamaaSpacing.lg),
              Text('اكتملت الرحلة!',
                  textAlign: TextAlign.center,
                  style: NamaaTypography.heading1),
              const SizedBox(height: NamaaSpacing.md),
              // Fare breakdown
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(NamaaSpacing.md),
                  child: Column(
                    children: [
                      _SummaryRow(
                        label: 'إجمالي الأجرة',
                        value:
                            '${trip.totalFare.toStringAsFixed(0)} ج.س',
                        isBold: true,
                      ),
                      const Divider(),
                      _SummaryRow(
                        label: 'أرباحك',
                        value:
                            '${trip.driverEarnings.toStringAsFixed(0)} ج.س',
                        valueColor: NamaaColors.primaryDark,
                        isBold: true,
                      ),
                      const Divider(),
                      _SummaryRow(
                        label: 'طريقة الدفع',
                        value: trip.paymentMethod == PaymentMethod.cash
                            ? 'نقداً'
                            : 'محفظة',
                      ),
                      if (trip.distanceKm != null) ...[
                        const Divider(),
                        _SummaryRow(
                          label: 'المسافة',
                          value:
                              '${trip.distanceKm!.toStringAsFixed(1)} كم',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'تقييم الراكب',
                onPressed: () =>
                    context.go(RouteNames.ratePassenger, extra: trip),
              ),
              const SizedBox(height: NamaaSpacing.md),
              OutlinedButton(
                onPressed: () => context.go(RouteNames.home),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: NamaaSpacing.md),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NamaaSpacing.md)),
                ),
                child: const Text('العودة للرئيسية'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: NamaaSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: NamaaTypography.bodyMedium
                .copyWith(color: NamaaColors.textSecondary),
          ),
          Text(
            value,
            style: isBold
                ? NamaaTypography.labelLarge
                    .copyWith(color: valueColor ?? NamaaColors.textPrimary)
                : NamaaTypography.bodyMedium
                    .copyWith(color: valueColor ?? NamaaColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
