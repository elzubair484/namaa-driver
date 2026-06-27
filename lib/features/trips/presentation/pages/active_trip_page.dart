import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/config/maps_config.dart';
import '../../../../core/router/route_names.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/components/buttons/primary_button.dart';
import '../../domain/entities/trip_entity.dart';
import '../providers/trip_provider.dart';

class ActiveTripPage extends ConsumerStatefulWidget {
  const ActiveTripPage({super.key, required this.trip});
  final TripEntity trip;

  @override
  ConsumerState<ActiveTripPage> createState() => _ActiveTripPageState();
}

class _ActiveTripPageState extends ConsumerState<ActiveTripPage> {
  late Duration _elapsed;
  Timer? _timer;
  bool _completing = false;

  @override
  void initState() {
    super.initState();
    _elapsed = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _elapsedFormatted {
    final m = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _completeTrip() async {
    setState(() => _completing = true);
    final trip = await ref
        .read(tripActionsProvider.notifier)
        .completeTrip(widget.trip.id);
    if (!mounted) return;
    if (trip != null) {
      context.go(RouteNames.tripCompletion, extra: trip);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: MapsConfig.khartoumCenter,
              zoom: MapsConfig.navigationZoom,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopBar(),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomSheet(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(NamaaSpacing.md),
        padding: const EdgeInsets.all(NamaaSpacing.md),
        decoration: BoxDecoration(
          color: NamaaColors.primaryDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الرحلة جارية',
                    style: NamaaTypography.labelLarge
                        .copyWith(color: NamaaColors.onPrimary)),
                Text(
                  widget.trip.dropoffAddress,
                  style: NamaaTypography.bodySmall.copyWith(
                    color: NamaaColors.onPrimary.withValues(alpha: 0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            // Elapsed timer
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: NamaaSpacing.md, vertical: NamaaSpacing.sm),
              decoration: BoxDecoration(
                color: NamaaColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _elapsedFormatted,
                style: NamaaTypography.heading3
                    .copyWith(color: NamaaColors.onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(NamaaSpacing.md),
      decoration: BoxDecoration(
        color: NamaaColors.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(
                  label: 'الوقت',
                  value: _elapsedFormatted,
                  icon: Icons.timer,
                ),
                _Stat(
                  label: 'الأجرة',
                  value:
                      '${widget.trip.totalFare.toStringAsFixed(0)} ج.س',
                  icon: Icons.attach_money,
                  color: NamaaColors.primaryDark,
                ),
                _Stat(
                  label: 'الراكب',
                  value: widget.trip.passengerName ?? 'الراكب',
                  icon: Icons.person,
                ),
              ],
            ),
            const SizedBox(height: NamaaSpacing.md),
            PrimaryButton(
              label: 'إنهاء الرحلة',
              isLoading: _completing,
              onPressed: _completeTrip,
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.icon, this.color});

  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color ?? NamaaColors.textSecondary, size: 22),
        const SizedBox(height: 4),
        Text(value,
            style: NamaaTypography.labelLarge
                .copyWith(color: color ?? NamaaColors.textPrimary)),
        Text(label,
            style: NamaaTypography.caption
                .copyWith(color: NamaaColors.textSecondary)),
      ],
    );
  }
}
