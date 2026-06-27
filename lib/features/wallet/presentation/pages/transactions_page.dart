import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/components/misc/namaa_app_bar.dart';
import '../../../../design_system/components/feedback/loading_state.dart';
import '../../../../design_system/components/feedback/empty_state.dart';
import '../../../../design_system/components/feedback/error_state.dart';
import '../providers/wallet_provider.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: NamaaColors.background,
      appBar: const NamaaAppBar(title: 'سجل المعاملات'),
      body: txAsync.when(
        data: (list) => list.isEmpty
            ? const EmptyState(
                title: 'لا توجد معاملات بعد',
                icon: Icons.receipt_long_outlined,
              )
            : ListView.builder(
                padding: const EdgeInsets.all(NamaaSpacing.md),
                itemCount: list.length,
                itemBuilder: (_, i) => _TxTile(list[i]),
              ),
        loading: () => const LoadingState(),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(transactionsProvider),
        ),
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  const _TxTile(this.tx);
  final TransactionEntity tx;

  @override
  Widget build(BuildContext context) {
    final isCredit = tx.type.isCredit;
    final color = isCredit ? NamaaColors.onlineGreen : NamaaColors.error;
    final sign = isCredit ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: NamaaSpacing.sm),
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
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: NamaaSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.type.labelAr, style: NamaaTypography.labelMedium),
                if (tx.description != null)
                  Text(
                    tx.description!,
                    style: NamaaTypography.bodySmall
                        .copyWith(color: NamaaColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  _formatDate(tx.createdAt),
                  style: NamaaTypography.caption
                      .copyWith(color: NamaaColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign${tx.amount.toStringAsFixed(2)} ج.س',
                style: NamaaTypography.labelLarge.copyWith(color: color),
              ),
              Text(
                'الرصيد: ${tx.balanceAfter.toStringAsFixed(2)}',
                style: NamaaTypography.caption
                    .copyWith(color: NamaaColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
  }
}
