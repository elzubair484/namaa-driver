import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/components/misc/namaa_app_bar.dart';
import '../../../../design_system/components/misc/rating_stars.dart';
import '../../../../design_system/components/feedback/loading_state.dart';
import '../../../../design_system/components/feedback/error_state.dart';
import '../providers/history_provider.dart';

class PerformancePage extends ConsumerWidget {
  const PerformancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(performanceProvider);

    return Scaffold(
      backgroundColor: NamaaColors.background,
      appBar: const NamaaAppBar(title: 'لوحة الأداء'),
      body: statsAsync.when(
        data: (data) => _PerformanceBody(data: data),
        loading: () => const LoadingState(),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(performanceProvider),
        ),
      ),
    );
  }
}

class _PerformanceBody extends StatelessWidget {
  const _PerformanceBody({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final driver = data['driver'] as Map<String, dynamic>? ?? {};
    final trips = data['trips'] as List? ?? [];

    final rating = (driver['rating'] as num?)?.toDouble() ?? 5.0;
    final totalTrips = (driver['total_trips'] as int?) ?? 0;
    final acceptanceRate =
        (driver['acceptance_rate'] as num?)?.toDouble() ?? 100.0;
    final completionRate =
        (driver['completion_rate'] as num?)?.toDouble() ?? 100.0;

    // Monthly breakdown
    final monthly = _buildMonthly(trips);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(NamaaSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Rating hero
          Container(
            padding: const EdgeInsets.all(NamaaSpacing.lg),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [NamaaColors.primaryDark, NamaaColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Column(
              children: [
                Text(
                  rating.toStringAsFixed(1),
                  style: NamaaTypography.displayLarge.copyWith(
                    color: NamaaColors.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 56,
                  ),
                ),
                RatingStars(rating: rating, size: 28),
                const SizedBox(height: NamaaSpacing.sm),
                Text('تقييمك العام',
                    style: NamaaTypography.bodyMedium
                        .copyWith(color: NamaaColors.onPrimary.withValues(alpha: 0.8))),
              ],
            ),
          ),

          const SizedBox(height: NamaaSpacing.md),

          // Key metrics
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'إجمالي الرحلات',
                  value: '$totalTrips',
                  icon: Icons.directions_car,
                ),
              ),
              const SizedBox(width: NamaaSpacing.sm),
              Expanded(
                child: _MetricCard(
                  label: 'نسبة القبول',
                  value: '${acceptanceRate.toStringAsFixed(0)}%',
                  icon: Icons.thumb_up_outlined,
                  valueColor: _rateColor(acceptanceRate),
                ),
              ),
              const SizedBox(width: NamaaSpacing.sm),
              Expanded(
                child: _MetricCard(
                  label: 'نسبة الإكمال',
                  value: '${completionRate.toStringAsFixed(0)}%',
                  icon: Icons.check_circle_outline,
                  valueColor: _rateColor(completionRate),
                ),
              ),
            ],
          ),

          const SizedBox(height: NamaaSpacing.md),

          // Monthly earnings chart (bar chart using containers)
          if (monthly.isNotEmpty) ...[
            Text('الأرباح الشهرية (آخر 6 أشهر)',
                style: NamaaTypography.heading3),
            const SizedBox(height: NamaaSpacing.md),
            Container(
              padding: const EdgeInsets.all(NamaaSpacing.md),
              decoration: BoxDecoration(
                color: NamaaColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: NamaaColors.divider),
              ),
              child: _BarChart(monthly: monthly),
            ),
            const SizedBox(height: NamaaSpacing.md),
          ],

          // Performance tips
          Text('نصائح لتحسين أدائك', style: NamaaTypography.heading3),
          const SizedBox(height: NamaaSpacing.sm),
          ..._tips(acceptanceRate, completionRate, rating)
              .map((t) => _TipCard(tip: t)),

          const SizedBox(height: NamaaSpacing.xxxl),
        ],
      ),
    );
  }

  Color _rateColor(double rate) {
    if (rate >= 90) return NamaaColors.onlineGreen;
    if (rate >= 70) return NamaaColors.primary;
    return NamaaColors.error;
  }

  List<_MonthData> _buildMonthly(List trips) {
    final now = DateTime.now();
    final map = <String, double>{};

    for (final trip in trips) {
      final t = trip as Map<String, dynamic>;
      final at = DateTime.tryParse(t['completed_at'] as String? ?? '');
      if (at == null) continue;
      final key = '${at.year}-${at.month.toString().padLeft(2, '0')}';
      map[key] = (map[key] ?? 0) + ((t['driver_earnings'] as num?)?.toDouble() ?? 0);
    }

    return List.generate(6, (i) {
      final d = DateTime(now.year, now.month - (5 - i));
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
      return _MonthData(
        label: _monthAr(d.month),
        amount: map[key] ?? 0,
      );
    });
  }

  String _monthAr(int m) => const [
        'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
      ][m - 1];

  List<String> _tips(double acceptance, double completion, double rating) {
    final tips = <String>[];
    if (acceptance < 80) {
      tips.add('حاول قبول المزيد من الرحلات لتحسين نسبة القبول وزيادة أرباحك.');
    }
    if (completion < 90) {
      tips.add('أكمل رحلاتك دون إلغاء لتحسين نسبة الإكمال والمصداقية.');
    }
    if (rating < 4.5) {
      tips.add('احرص على التواصل الجيد مع الركاب وتقديم خدمة ممتازة لرفع تقييمك.');
    }
    if (tips.isEmpty) {
      tips.add('أداؤك ممتاز! استمر على هذا المستوى للحفاظ على تقييمك المرتفع.');
    }
    return tips;
  }
}

class _MonthData {
  const _MonthData({required this.label, required this.amount});
  final String label;
  final double amount;
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.monthly});
  final List<_MonthData> monthly;

  @override
  Widget build(BuildContext context) {
    final maxAmount = monthly.fold(0.0, (m, d) => d.amount > m ? d.amount : m);
    final chartMax = maxAmount == 0 ? 1.0 : maxAmount;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: monthly.map((m) {
        final fraction = m.amount / chartMax;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  m.amount > 0 ? '${m.amount.toStringAsFixed(0)}' : '',
                  style: NamaaTypography.caption
                      .copyWith(color: NamaaColors.primaryDark, fontSize: 9),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Container(
                  height: 120 * fraction + 4,
                  decoration: BoxDecoration(
                    color: NamaaColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  m.label,
                  style: NamaaTypography.caption
                      .copyWith(color: NamaaColors.textSecondary, fontSize: 9),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(
      {required this.label,
      required this.value,
      required this.icon,
      this.valueColor});
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(NamaaSpacing.md),
      decoration: BoxDecoration(
        color: NamaaColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NamaaColors.divider),
      ),
      child: Column(
        children: [
          Icon(icon, color: NamaaColors.primaryDark, size: 24),
          const SizedBox(height: NamaaSpacing.xs),
          Text(value,
              style: NamaaTypography.heading2
                  .copyWith(color: valueColor ?? NamaaColors.textPrimary)),
          Text(label,
              style: NamaaTypography.caption
                  .copyWith(color: NamaaColors.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip});
  final String tip;

  @override
  Widget build(BuildContext context) {
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
          const Icon(Icons.lightbulb_outline, color: NamaaColors.primary),
          const SizedBox(width: NamaaSpacing.sm),
          Expanded(child: Text(tip, style: NamaaTypography.bodyMedium)),
        ],
      ),
    );
  }
}
