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

class NavigatingPage extends ConsumerStatefulWidget {
  const NavigatingPage({super.key, required this.trip});
  final TripEntity trip;

  @override
  ConsumerState<NavigatingPage> createState() => _NavigatingPageState();
}

class _NavigatingPageState extends ConsumerState<NavigatingPage> {
  bool _arriving = false;

  Future<void> _markArrived() async {
    setState(() => _arriving = true);
    final trip = await ref
        .read(tripActionsProvider.notifier)
        .markArrived(widget.trip.id);
    if (!mounted) return;
    if (trip != null) {
      context.go(RouteNames.passengerPickup,
          extra: trip);
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
            child: _buildTopBar(context),
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

  Widget _buildTopBar(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(NamaaSpacing.md),
        padding: const EdgeInsets.symmetric(
            horizontal: NamaaSpacing.md, vertical: NamaaSpacing.sm),
        decoration: BoxDecoration(
          color: NamaaColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
            )
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.navigation, color: NamaaColors.primaryDark),
            const SizedBox(width: NamaaSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('في الطريق للراكب',
                      style: NamaaTypography.labelLarge),
                  Text(
                    widget.trip.pickupAddress,
                    style: NamaaTypography.bodySmall
                        .copyWith(color: NamaaColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
              children: [
                const Icon(Icons.person, color: NamaaColors.primaryDark, size: 32),
                const SizedBox(width: NamaaSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.trip.passengerName ?? 'الراكب',
                        style: NamaaTypography.heading3,
                      ),
                      Text(
                        widget.trip.pickupAddress,
                        style: NamaaTypography.bodySmall
                            .copyWith(color: NamaaColors.textSecondary),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                if (widget.trip.passengerPhone != null)
                  IconButton(
                    icon: const Icon(Icons.phone,
                        color: NamaaColors.primaryDark),
                    onPressed: () {},
                  ),
              ],
            ),
            const SizedBox(height: NamaaSpacing.md),
            PrimaryButton(
              label: 'وصلت لنقطة الاستقبال',
              isLoading: _arriving,
              onPressed: _markArrived,
            ),
          ],
        ),
      ),
    );
  }
}
