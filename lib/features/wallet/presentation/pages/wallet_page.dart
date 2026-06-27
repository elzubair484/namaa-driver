import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/components/feedback/loading_state.dart';
import '../../../../design_system/components/feedback/error_state.dart';
import '../providers/wallet_provider.dart';
import '../../domain/entities/withdrawal_entity.dart';

class WalletPage extends ConsumerWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletProvider);
    final withdrawalsAsync = ref.watch(withdrawalsProvider);

    return Scaffold(
      backgroundColor: NamaaColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Gold header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(NamaaSpacing.lg),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [NamaaColors.primaryDark, NamaaColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: walletAsync.when(
                  data: (wallet) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('رصيدك المتاح',
                          style: NamaaTypography.bodyMedium
                              .copyWith(color: NamaaColors.onPrimary.withValues(alpha: 0.8))),
                      const SizedBox(height: NamaaSpacing.sm),
                      Text(
                        wallet == null
                            ? '٠ ج.س'
                            : '${wallet.availableBalance.toStringAsFixed(2)} ج.س',
                        style: NamaaTypography.displayLarge.copyWith(
                          color: NamaaColors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: NamaaSpacing.md),
                      Row(
                        children: [
                          _MiniStat(
                            label: 'إجمالي الأرباح',
                            value: '${wallet?.totalEarned.toStringAsFixed(0) ?? '٠'} ج.س',
                          ),
                          const SizedBox(width: NamaaSpacing.md),
                          _MiniStat(
                            label: 'المسحوب',
                            value: '${wallet?.totalWithdrawn.toStringAsFixed(0) ?? '٠'} ج.س',
                          ),
                          const SizedBox(width: NamaaSpacing.md),
                          _MiniStat(
                            label: 'العمولات',
                            value: '${wallet?.totalCommission.toStringAsFixed(0) ?? '٠'} ج.س',
                          ),
                        ],
                      ),
                      if ((wallet?.pendingWithdrawal ?? 0) > 0) ...[
                        const SizedBox(height: NamaaSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: NamaaSpacing.md,
                              vertical: NamaaSpacing.sm),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'سحب معلق: ${wallet!.pendingWithdrawal.toStringAsFixed(2)} ج.س',
                            style: NamaaTypography.bodySmall
                                .copyWith(color: NamaaColors.onPrimary),
                          ),
                        ),
                      ],
                    ],
                  ),
                  loading: () => const SizedBox(
                    height: 120,
                    child: Center(
                        child: CircularProgressIndicator(
                            color: NamaaColors.onPrimary)),
                  ),
                  error: (e, _) => SizedBox(
                    height: 120,
                    child: Center(
                      child: TextButton.icon(
                        onPressed: () => ref.invalidate(walletProvider),
                        icon: const Icon(Icons.refresh, color: NamaaColors.onPrimary),
                        label: const Text('إعادة المحاولة',
                            style: TextStyle(color: NamaaColors.onPrimary)),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Action buttons
            SliverPadding(
              padding: const EdgeInsets.all(NamaaSpacing.md),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.history,
                        label: 'السجل',
                        onTap: () => context.push(RouteNames.transactions),
                      ),
                    ),
                    const SizedBox(width: NamaaSpacing.md),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.upload,
                        label: 'سحب',
                        onTap: () => context.push(RouteNames.withdrawal),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Recent withdrawals
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: NamaaSpacing.md),
              sliver: SliverToBoxAdapter(
                child: Text('طلبات السحب الأخيرة',
                    style: NamaaTypography.heading3),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: NamaaSpacing.sm)),
            withdrawalsAsync.when(
              data: (list) => list.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(NamaaSpacing.md),
                        child: Text('لا توجد طلبات سحب',
                            style: NamaaTypography.bodyMedium.copyWith(
                                color: NamaaColors.textSecondary)),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _WithdrawalTile(list[i]),
                        childCount: list.length,
                      ),
                    ),
              loading: () => const SliverToBoxAdapter(child: LoadingState()),
              error: (e, _) => SliverToBoxAdapter(
                child: ErrorState(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(withdrawalsProvider),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: NamaaSpacing.xxxl)),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: NamaaTypography.caption.copyWith(
                  color: NamaaColors.onPrimary.withValues(alpha: 0.7))),
          Text(value,
              style: NamaaTypography.labelMedium
                  .copyWith(color: NamaaColors.onPrimary)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: NamaaSpacing.md),
        decoration: BoxDecoration(
          color: NamaaColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: NamaaColors.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: NamaaColors.primaryDark, size: 28),
            const SizedBox(height: NamaaSpacing.xs),
            Text(label, style: NamaaTypography.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _WithdrawalTile extends StatelessWidget {
  const _WithdrawalTile(this.w);
  final WithdrawalEntity w;

  @override
  Widget build(BuildContext context) {
    final color = switch (w.status) {
      WithdrawalStatus.completed => NamaaColors.onlineGreen,
      WithdrawalStatus.rejected => NamaaColors.error,
      _ => NamaaColors.primary,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: NamaaSpacing.md, vertical: NamaaSpacing.xs),
      child: Container(
        padding: const EdgeInsets.all(NamaaSpacing.md),
        decoration: BoxDecoration(
          color: NamaaColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: NamaaColors.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(NamaaSpacing.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.upload, color: color, size: 20),
            ),
            const SizedBox(width: NamaaSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${w.amount.toStringAsFixed(0)} ج.س',
                      style: NamaaTypography.labelLarge),
                  Text(w.bankName,
                      style: NamaaTypography.bodySmall
                          .copyWith(color: NamaaColors.textSecondary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: NamaaSpacing.sm, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(w.status.labelAr,
                  style: NamaaTypography.caption.copyWith(color: color)),
            ),
          ],
        ),
      ),
    );
  }
}
