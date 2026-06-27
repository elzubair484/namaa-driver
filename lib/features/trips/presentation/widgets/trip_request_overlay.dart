import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../domain/entities/trip_entity.dart';
import '../providers/trip_provider.dart';

class TripRequestOverlay extends ConsumerStatefulWidget {
  const TripRequestOverlay({super.key, required this.trip, required this.onDone});

  final TripEntity trip;
  final VoidCallback onDone;

  @override
  ConsumerState<TripRequestOverlay> createState() => _TripRequestOverlayState();
}

class _TripRequestOverlayState extends ConsumerState<TripRequestOverlay>
    with SingleTickerProviderStateMixin {
  late int _secondsLeft;
  Timer? _timer;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _secondsLeft = AppConfig.tripRequestTimeoutSeconds;
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _secondsLeft),
    )..forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        _reject();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _accept() async {
    _timer?.cancel();
    await ref.read(tripActionsProvider.notifier).accept(widget.trip.id);
    widget.onDone();
  }

  Future<void> _reject() async {
    _timer?.cancel();
    await ref.read(tripActionsProvider.notifier).reject(widget.trip.id);
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.all(NamaaSpacing.md),
            decoration: BoxDecoration(
              color: NamaaColors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 24,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Timer bar
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (_, __) => LinearProgressIndicator(
                      value: 1 - _progressController.value,
                      backgroundColor: NamaaColors.divider,
                      valueColor: AlwaysStoppedAnimation(
                        _secondsLeft > 10
                            ? NamaaColors.primary
                            : NamaaColors.error,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(NamaaSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(NamaaSpacing.sm),
                            decoration: BoxDecoration(
                              color: NamaaColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.directions_car,
                                color: NamaaColors.primaryDark, size: 28),
                          ),
                          const SizedBox(width: NamaaSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('طلب رحلة جديد',
                                    style: NamaaTypography.heading3),
                                Text(
                                  '${widget.trip.distanceKm?.toStringAsFixed(1) ?? '--'} كم • ${widget.trip.durationMinutes ?? '--'} دقيقة',
                                  style: NamaaTypography.bodySmall.copyWith(
                                    color: NamaaColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Countdown
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: _secondsLeft > 10
                                  ? NamaaColors.primaryLight
                                  : NamaaColors.error.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$_secondsLeft',
                                style: NamaaTypography.heading2.copyWith(
                                  color: _secondsLeft > 10
                                      ? NamaaColors.primaryDark
                                      : NamaaColors.error,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: NamaaSpacing.md),
                      const Divider(),
                      const SizedBox(height: NamaaSpacing.sm),

                      // Route
                      _RouteRow(
                        icon: Icons.radio_button_checked,
                        iconColor: NamaaColors.onlineGreen,
                        label: 'نقطة الاستقبال',
                        address: widget.trip.pickupAddress,
                      ),
                      const SizedBox(height: NamaaSpacing.sm),
                      _RouteRow(
                        icon: Icons.location_on,
                        iconColor: NamaaColors.error,
                        label: 'الوجهة',
                        address: widget.trip.dropoffAddress,
                      ),

                      const SizedBox(height: NamaaSpacing.md),

                      // Fare + payment
                      Row(
                        children: [
                          _FareChip(
                            label: 'الأجرة',
                            value:
                                '${widget.trip.totalFare.toStringAsFixed(0)} ج.س',
                          ),
                          const SizedBox(width: NamaaSpacing.sm),
                          _FareChip(
                            label: 'الدفع',
                            value: widget.trip.paymentMethod ==
                                    PaymentMethod.cash
                                ? 'نقداً'
                                : 'محفظة',
                            valueColor:
                                widget.trip.paymentMethod == PaymentMethod.cash
                                    ? NamaaColors.onlineGreen
                                    : NamaaColors.primaryDark,
                          ),
                          const SizedBox(width: NamaaSpacing.sm),
                          _FareChip(
                            label: 'أرباحك',
                            value:
                                '${widget.trip.driverEarnings.toStringAsFixed(0)} ج.س',
                            valueColor: NamaaColors.primaryDark,
                          ),
                        ],
                      ),

                      const SizedBox(height: NamaaSpacing.md),

                      // Accept / Reject buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _reject,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: NamaaColors.error,
                                side: const BorderSide(
                                    color: NamaaColors.error),
                                padding: const EdgeInsets.symmetric(
                                    vertical: NamaaSpacing.md),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(NamaaSpacing.md)),
                              ),
                              child: const Text('رفض'),
                            ),
                          ),
                          const SizedBox(width: NamaaSpacing.md),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _accept,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: NamaaColors.primary,
                                foregroundColor: NamaaColors.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                    vertical: NamaaSpacing.md),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(NamaaSpacing.md)),
                              ),
                              child: const Text('قبول',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.address,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: NamaaSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: NamaaTypography.caption
                      .copyWith(color: NamaaColors.textSecondary)),
              Text(address,
                  style: NamaaTypography.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}

class _FareChip extends StatelessWidget {
  const _FareChip({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: NamaaSpacing.sm, horizontal: NamaaSpacing.sm),
        decoration: BoxDecoration(
          color: NamaaColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label,
                style: NamaaTypography.caption
                    .copyWith(color: NamaaColors.textSecondary)),
            const SizedBox(height: 2),
            Text(
              value,
              style: NamaaTypography.labelLarge.copyWith(
                color: valueColor ?? NamaaColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
