import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/components/misc/namaa_app_bar.dart';
import '../../../../design_system/components/misc/rating_stars.dart';
import '../../../../design_system/components/feedback/loading_state.dart';
import '../../../../design_system/components/feedback/error_state.dart';
import '../../../trips/domain/entities/trip_entity.dart';
import '../providers/history_provider.dart';

class TripDetailPage extends ConsumerWidget {
  const TripDetailPage({super.key, required this.tripId});
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripDetailProvider(tripId));

    return Scaffold(
      backgroundColor: NamaaColors.background,
      appBar: const NamaaAppBar(title: 'تفاصيل الرحلة'),
      body: tripAsync.when(
        data: (trip) =>
            trip == null ? const ErrorState(message: 'الرحلة غير موجودة') : _TripDetail(trip: trip),
        loading: () => const LoadingState(),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(tripDetailProvider(tripId)),
        ),
      ),
    );
  }
}

class _TripDetail extends StatelessWidget {
  const _TripDetail({required this.trip});
  final TripEntity trip;

  @override
  Widget build(BuildContext context) {
    final isCompleted = trip.status == TripStatus.completed;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(NamaaSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status banner
          Container(
            padding: const EdgeInsets.all(NamaaSpacing.md),
            decoration: BoxDecoration(
              color: isCompleted
                  ? NamaaColors.onlineGreen.withValues(alpha: 0.1)
                  : NamaaColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCompleted
                    ? NamaaColors.onlineGreen
                    : NamaaColors.error,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.cancel,
                  color: isCompleted
                      ? NamaaColors.onlineGreen
                      : NamaaColors.error,
                ),
                const SizedBox(width: NamaaSpacing.sm),
                Text(
                  isCompleted ? 'رحلة مكتملة' : 'رحلة ملغاة',
                  style: NamaaTypography.labelLarge.copyWith(
                    color: isCompleted
                        ? NamaaColors.onlineGreen
                        : NamaaColors.error,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(trip.requestedAt),
                  style: NamaaTypography.bodySmall
                      .copyWith(color: NamaaColors.textSecondary),
                ),
              ],
            ),
          ),

          const SizedBox(height: NamaaSpacing.md),

          // Route card
          _Card(
            title: 'مسار الرحلة',
            child: Column(
              children: [
                _RouteRow(
                  icon: Icons.radio_button_checked,
                  color: NamaaColors.onlineGreen,
                  label: 'نقطة الاستقبال',
                  address: trip.pickupAddress,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      right: NamaaSpacing.sm, top: 4, bottom: 4),
                  child: const Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      height: 20,
                      child: VerticalDivider(width: 1),
                    ),
                  ),
                ),
                _RouteRow(
                  icon: Icons.location_on,
                  color: NamaaColors.error,
                  label: 'الوجهة',
                  address: trip.dropoffAddress,
                ),
                if (trip.distanceKm != null) ...[
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        label: 'المسافة',
                        value: '${trip.distanceKm!.toStringAsFixed(1)} كم',
                      ),
                      if (trip.durationMinutes != null)
                        _StatItem(
                          label: 'المدة',
                          value: '${trip.durationMinutes} دقيقة',
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: NamaaSpacing.md),

          // Fare breakdown
          if (isCompleted)
            _Card(
              title: 'تفاصيل الأجرة',
              child: Column(
                children: [
                  _FareRow(label: 'إجمالي الأجرة',
                      value: '${trip.totalFare.toStringAsFixed(2)} ج.س'),
                  const Divider(),
                  _FareRow(
                    label: 'أرباحك',
                    value: '${trip.driverEarnings.toStringAsFixed(2)} ج.س',
                    valueColor: NamaaColors.primaryDark,
                    bold: true,
                  ),
                  const Divider(),
                  _FareRow(
                    label: 'طريقة الدفع',
                    value: trip.paymentMethod == PaymentMethod.cash
                        ? 'نقداً'
                        : 'محفظة',
                  ),
                ],
              ),
            ),

          const SizedBox(height: NamaaSpacing.md),

          // Passenger rating
          if (trip.passengerRating != null)
            _Card(
              title: 'تقييمك للراكب',
              child: Row(
                children: [
                  RatingStars(
                    rating: trip.passengerRating!.toDouble(),
                    size: 24,
                  ),
                  const SizedBox(width: NamaaSpacing.sm),
                  Text(
                    '${trip.passengerRating}/5',
                    style: NamaaTypography.labelLarge,
                  ),
                ],
              ),
            ),

          const SizedBox(height: NamaaSpacing.md),

          // Timeline
          _Card(
            title: 'التسلسل الزمني',
            child: Column(
              children: [
                _TimelineRow(
                    label: 'طلب الرحلة', time: trip.requestedAt),
                if (trip.acceptedAt != null)
                  _TimelineRow(
                      label: 'قبول الرحلة', time: trip.acceptedAt!),
                if (trip.startedAt != null)
                  _TimelineRow(
                      label: 'بدء الرحلة', time: trip.startedAt!),
                if (trip.completedAt != null)
                  _TimelineRow(
                      label: 'اكتمال الرحلة',
                      time: trip.completedAt!,
                      isLast: true),
              ],
            ),
          ),

          const SizedBox(height: NamaaSpacing.xxxl),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ── Sub-widgets ───────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});
  final String title;
  final Widget child;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: NamaaTypography.heading3),
          const SizedBox(height: NamaaSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow(
      {required this.icon,
      required this.color,
      required this.label,
      required this.address});
  final IconData icon;
  final Color color;
  final String label;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: NamaaSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: NamaaTypography.caption
                      .copyWith(color: NamaaColors.textSecondary)),
              Text(address, style: NamaaTypography.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: NamaaTypography.labelLarge),
        Text(label,
            style: NamaaTypography.caption
                .copyWith(color: NamaaColors.textSecondary)),
      ],
    );
  }
}

class _FareRow extends StatelessWidget {
  const _FareRow(
      {required this.label,
      required this.value,
      this.valueColor,
      this.bold = false});
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

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
              style: (bold ? NamaaTypography.labelLarge : NamaaTypography.bodyMedium)
                  .copyWith(color: valueColor ?? NamaaColors.textPrimary)),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow(
      {required this.label, required this.time, this.isLast = false});
  final String label;
  final DateTime time;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: NamaaColors.primaryDark,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: NamaaColors.divider,
              ),
          ],
        ),
        const SizedBox(width: NamaaSpacing.sm),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: NamaaSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: NamaaTypography.labelMedium),
                Text(
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  style: NamaaTypography.caption
                      .copyWith(color: NamaaColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
