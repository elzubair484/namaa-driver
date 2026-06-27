import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/components/feedback/empty_state.dart';
import '../../../../design_system/components/feedback/error_state.dart';
import '../../../trips/domain/entities/trip_entity.dart';
import '../providers/history_provider.dart';

class TripHistoryPage extends ConsumerStatefulWidget {
  const TripHistoryPage({super.key});

  @override
  ConsumerState<TripHistoryPage> createState() => _TripHistoryPageState();
}

class _TripHistoryPageState extends ConsumerState<TripHistoryPage> {
  final _scrollCtrl = ScrollController();
  TripStatus? _filter;

  static const _filters = [
    (null, 'الكل'),
    (TripStatus.completed, 'مكتملة'),
    (TripStatus.cancelled, 'ملغاة'),
  ];

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        ref.read(tripHistoryProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tripHistoryProvider);

    return Scaffold(
      backgroundColor: NamaaColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with performance link
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  NamaaSpacing.md, NamaaSpacing.md, NamaaSpacing.md, 0),
              child: Row(
                children: [
                  Text('الرحلات', style: NamaaTypography.heading1),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => context.push(RouteNames.performance),
                    icon: const Icon(Icons.bar_chart,
                        color: NamaaColors.primaryDark),
                    label: Text('الأداء',
                        style: NamaaTypography.labelMedium
                            .copyWith(color: NamaaColors.primaryDark)),
                  ),
                ],
              ),
            ),
            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: NamaaSpacing.md, vertical: NamaaSpacing.sm),
              child: Row(
                children: _filters.map((f) {
                  final selected = _filter == f.$1;
                  return Padding(
                    padding: const EdgeInsets.only(left: NamaaSpacing.sm),
                    child: FilterChip(
                      label: Text(f.$2),
                      selected: selected,
                      onSelected: (_) {
                        setState(() => _filter = f.$1);
                        ref
                            .read(tripHistoryProvider.notifier)
                            .setFilter(f.$1);
                      },
                      selectedColor: NamaaColors.primaryLight,
                      checkmarkColor: NamaaColors.primaryDark,
                    ),
                  );
                }).toList(),
              ),
            ),
            // Trip list
            Expanded(
              child: () {
                if (state.error != null && state.trips.isEmpty) {
                  return ErrorState(
                    message: state.error!,
                    onRetry: () =>
                        ref.read(tripHistoryProvider.notifier).refresh(),
                  );
                }
                if (state.isLoading && state.trips.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.trips.isEmpty) {
                  return const EmptyState(
                    title: 'لا توجد رحلات',
                    icon: Icons.directions_car_outlined,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(tripHistoryProvider.notifier).refresh(),
                  child: ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(NamaaSpacing.md),
                    itemCount:
                        state.trips.length + (state.hasMore ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == state.trips.length) {
                        return const Padding(
                          padding: EdgeInsets.all(NamaaSpacing.md),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return _TripTile(
                        trip: state.trips[i],
                        onTap: () => context.push(
                          '/history/${state.trips[i].id}',
                        ),
                      );
                    },
                  ),
                );
              }(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripTile extends StatelessWidget {
  const _TripTile({required this.trip, required this.onTap});
  final TripEntity trip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCompleted = trip.status == TripStatus.completed;
    final statusColor = isCompleted ? NamaaColors.onlineGreen : NamaaColors.error;
    final statusLabel = isCompleted ? 'مكتملة' : 'ملغاة';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: NamaaSpacing.sm),
        padding: const EdgeInsets.all(NamaaSpacing.md),
        decoration: BoxDecoration(
          color: NamaaColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: NamaaColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(NamaaSpacing.sm),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.directions_car,
                      color: statusColor, size: 18),
                ),
                const SizedBox(width: NamaaSpacing.sm),
                Expanded(
                  child: Text(
                    _formatDate(trip.requestedAt),
                    style: NamaaTypography.bodySmall
                        .copyWith(color: NamaaColors.textSecondary),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: NamaaSpacing.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(statusLabel,
                      style: NamaaTypography.caption
                          .copyWith(color: statusColor)),
                ),
              ],
            ),
            const SizedBox(height: NamaaSpacing.sm),
            _RouteRow(
                icon: Icons.radio_button_checked,
                color: NamaaColors.onlineGreen,
                text: trip.pickupAddress),
            const SizedBox(height: 4),
            _RouteRow(
                icon: Icons.location_on,
                color: NamaaColors.error,
                text: trip.dropoffAddress),
            if (isCompleted) ...[
              const Divider(height: NamaaSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Chip(
                    label: '${trip.driverEarnings.toStringAsFixed(0)} ج.س',
                    icon: Icons.attach_money,
                    color: NamaaColors.primaryDark,
                  ),
                  if (trip.distanceKm != null)
                    _Chip(
                      label: '${trip.distanceKm!.toStringAsFixed(1)} كم',
                      icon: Icons.straighten,
                    ),
                  _Chip(
                    label: trip.paymentMethod == PaymentMethod.cash
                        ? 'نقداً'
                        : 'محفظة',
                    icon: Icons.payments_outlined,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow(
      {required this.icon, required this.color, required this.text});
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: NamaaSpacing.xs),
        Expanded(
          child: Text(text,
              style: NamaaTypography.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.icon, this.color});
  final String label;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color ?? NamaaColors.textSecondary),
        const SizedBox(width: 4),
        Text(label,
            style: NamaaTypography.caption
                .copyWith(color: color ?? NamaaColors.textSecondary)),
      ],
    );
  }
}
