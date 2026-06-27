import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/components/feedback/loading_state.dart';
import '../../../../design_system/components/feedback/error_state.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';

class EarningsPage extends ConsumerWidget {
  const EarningsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletProvider);
    final breakdownAsync = ref.watch(earningsBreakdownProvider);

    return Scaffold(
      backgroundColor: NamaaColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(NamaaSpacing.lg),
                color: NamaaColors.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الأرباح',
                        style: NamaaTypography.heading1
                            .copyWith(color: NamaaColors.onPrimary)),
                    const SizedBox(height: NamaaSpacing.sm),
                    walletAsync.when(
                      data: (w) => Text(
                        '${w?.totalEarned.toStringAsFixed(2) ?? '٠'} ج.س',
                        style: NamaaTypography.displayLarge.copyWith(
                          color: NamaaColors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      loading: () => const CircularProgressIndicator(
                          color: NamaaColors.onPrimary),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    Text('إجمالي الأرباح منذ الانضمام',
                        style: NamaaTypography.bodySmall.copyWith(
                            color: NamaaColors.onPrimary.withValues(alpha: 0.8))),
                  ],
                ),
              ),
            ),

            // Period breakdown
            SliverPadding(
              padding: const EdgeInsets.all(NamaaSpacing.md),
              sliver: SliverToBoxAdapter(
                child: breakdownAsync.when(
                  data: (b) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('ملخص الأرباح', style: NamaaTypography.heading3),
                      const SizedBox(height: NamaaSpacing.md),
                      Row(
                        children: [
                          _PeriodCard(
                            label: 'اليوم',
                            amount: b['today'] ?? 0,
                          ),
                          const SizedBox(width: NamaaSpacing.sm),
                          _PeriodCard(
                            label: 'هذا الأسبوع',
                            amount: b['week'] ?? 0,
                          ),
                          const SizedBox(width: NamaaSpacing.sm),
                          _PeriodCard(
                            label: 'هذا الشهر',
                            amount: b['month'] ?? 0,
                            highlight: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                  loading: () => const LoadingState(),
                  error: (e, _) => ErrorState(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(earningsBreakdownProvider),
                  ),
                ),
              ),
            ),

            // Wallet stats
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: NamaaSpacing.md),
              sliver: SliverToBoxAdapter(
                child: walletAsync.when(
                  data: (w) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('إحصائيات المحفظة',
                          style: NamaaTypography.heading3),
                      const SizedBox(height: NamaaSpacing.md),
                      _StatRow(
                        label: 'الرصيد المتاح',
                        value:
                            '${w?.availableBalance.toStringAsFixed(2) ?? '٠'} ج.س',
                        valueColor: NamaaColors.onlineGreen,
                      ),
                      const Divider(),
                      _StatRow(
                        label: 'إجمالي المسحوب',
                        value:
                            '${w?.totalWithdrawn.toStringAsFixed(2) ?? '٠'} ج.س',
                      ),
                      const Divider(),
                      _StatRow(
                        label: 'العمولات المخصومة',
                        value:
                            '${w?.totalCommission.toStringAsFixed(2) ?? '٠'} ج.س',
                        valueColor: NamaaColors.error,
                      ),
                      if ((w?.pendingWithdrawal ?? 0) > 0) ...[
                        const Divider(),
                        _StatRow(
                          label: 'سحب معلق',
                          value:
                              '${w!.pendingWithdrawal.toStringAsFixed(2)} ج.س',
                          valueColor: NamaaColors.primary,
                        ),
                      ],
                    ],
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ),
            const SliverToBoxAdapter(
                child: SizedBox(height: NamaaSpacing.xxxl)),
          ],
        ),
      ),
    );
  }
}

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({
    required this.label,
    required this.amount,
    this.highlight = false,
  });

  final String label;
  final double amount;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(NamaaSpacing.md),
        decoration: BoxDecoration(
          color: highlight ? NamaaColors.primaryLight : NamaaColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: highlight ? NamaaColors.primary : NamaaColors.divider,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: NamaaTypography.caption
                    .copyWith(color: NamaaColors.textSecondary)),
            const SizedBox(height: NamaaSpacing.xs),
            Text(
              '${amount.toStringAsFixed(0)} ج.س',
              style: NamaaTypography.labelLarge.copyWith(
                color: highlight
                    ? NamaaColors.primaryDark
                    : NamaaColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: NamaaSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: NamaaTypography.bodyMedium
                  .copyWith(color: NamaaColors.textSecondary)),
          Text(value,
              style: NamaaTypography.labelLarge
                  .copyWith(color: valueColor ?? NamaaColors.textPrimary)),
        ],
      ),
    );
  }
}
