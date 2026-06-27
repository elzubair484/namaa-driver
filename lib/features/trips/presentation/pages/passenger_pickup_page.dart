import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/components/buttons/primary_button.dart';
import '../../../../design_system/components/misc/rating_stars.dart';
import '../../domain/entities/trip_entity.dart';
import '../providers/trip_provider.dart';

class PassengerPickupPage extends ConsumerStatefulWidget {
  const PassengerPickupPage({super.key, required this.trip});
  final TripEntity trip;

  @override
  ConsumerState<PassengerPickupPage> createState() =>
      _PassengerPickupPageState();
}

class _PassengerPickupPageState extends ConsumerState<PassengerPickupPage> {
  bool _starting = false;

  Future<void> _startTrip() async {
    setState(() => _starting = true);
    final trip = await ref
        .read(tripActionsProvider.notifier)
        .startTrip(widget.trip.id);
    if (!mounted) return;
    if (trip != null) {
      context.go(RouteNames.activeTrip, extra: trip);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NamaaColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status banner
            Container(
              color: NamaaColors.primary,
              padding: const EdgeInsets.all(NamaaSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.where_to_vote,
                      color: NamaaColors.onPrimary),
                  const SizedBox(width: NamaaSpacing.sm),
                  Text(
                    'وصلت لنقطة الاستقبال',
                    style: NamaaTypography.heading3
                        .copyWith(color: NamaaColors.onPrimary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: NamaaSpacing.lg),

            // Passenger card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: NamaaSpacing.md),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(NamaaSpacing.md),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 36,
                        backgroundColor: NamaaColors.primaryLight,
                        child: Icon(Icons.person,
                            size: 40, color: NamaaColors.primaryDark),
                      ),
                      const SizedBox(height: NamaaSpacing.sm),
                      Text(widget.trip.passengerName ?? 'الراكب',
                          style: NamaaTypography.heading2),
                      if (widget.trip.passengerPhone != null)
                        Text(
                          widget.trip.passengerPhone!,
                          style: NamaaTypography.bodyMedium
                              .copyWith(color: NamaaColors.textSecondary),
                        ),
                      const SizedBox(height: NamaaSpacing.sm),
                      RatingStars(rating: 4.8, size: 20),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: NamaaSpacing.md),

            // Route summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: NamaaSpacing.md),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(NamaaSpacing.md),
                  child: Column(
                    children: [
                      _RouteRow(
                          icon: Icons.radio_button_checked,
                          color: NamaaColors.onlineGreen,
                          address: widget.trip.pickupAddress),
                      const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: SizedBox(
                          height: 20,
                          child: VerticalDivider(
                              width: 1, color: NamaaColors.divider),
                        ),
                      ),
                      _RouteRow(
                          icon: Icons.location_on,
                          color: NamaaColors.error,
                          address: widget.trip.dropoffAddress),
                    ],
                  ),
                ),
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.all(NamaaSpacing.md),
              child: PrimaryButton(
                label: 'ابدأ الرحلة',
                isLoading: _starting,
                onPressed: _startTrip,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({
    required this.icon,
    required this.color,
    required this.address,
  });

  final IconData icon;
  final Color color;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: NamaaSpacing.sm),
        Expanded(
          child: Text(address,
              style: NamaaTypography.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
