import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/components/buttons/toggle_button.dart';
import '../../../../design_system/components/cards/stat_card.dart';
import '../../../../design_system/components/cards/earnings_card.dart';
import '../../../../design_system/components/misc/avatar_widget.dart';
import '../../../trips/domain/entities/trip_entity.dart';
import '../../../trips/presentation/providers/trip_provider.dart';
import '../../../trips/presentation/widgets/trip_request_overlay.dart';
import '../../../../design_system/components/misc/status_badge.dart';
import '../../../../core/config/maps_config.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/router/route_names.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/home_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  GoogleMapController? _mapController;

  static const _khartoum = CameraPosition(
    target: MapsConfig.khartoumCenter,
    zoom: MapsConfig.defaultZoom,
  );

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // Save FCM token once the driver is confirmed active
      final driver = ref.read(currentDriverProvider).valueOrNull;
      if (driver != null) {
        NotificationService.instance.saveToken(driver.id);
      }

      // Navigate when user taps a notification
      NotificationService.instance.onTap = (data) {
        final type = data['type'] as String?;
        if (!mounted) return;
        switch (type) {
          case 'trip_request':
            context.go(RouteNames.home);
          case 'support':
            context.go(RouteNames.support);
          case 'payment':
            context.go(RouteNames.wallet);
          case 'notification':
          default:
            context.go(RouteNames.notifications);
        }
      };
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _toggle() async {
    await ref.read(driverStatusProvider.notifier).toggle();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(driverStatusProvider).valueOrNull ?? false;
    final isLoading = ref.watch(driverStatusProvider).isLoading;
    final driver = ref.watch(liveDriverProvider).valueOrNull;
    final earnings = ref.watch(todayEarningsProvider);
    final activeTrip = ref.watch(activeTripProvider).valueOrNull;

    // Show trip request overlay when a new request arrives
    final showOverlay =
        isOnline && activeTrip?.status == TripStatus.requested;

    return Scaffold(
      backgroundColor: NamaaColors.background,
      body: Stack(
        children: [
          // Full-screen map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _khartoum,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Trip request overlay
          if (showOverlay && activeTrip != null)
            Positioned.fill(
              child: TripRequestOverlay(
                trip: activeTrip,
                onDone: () {},
              ),
            ),

          // Bottom sheet with status + stats (hidden while overlay shown)
          if (!showOverlay)
          DraggableScrollableSheet(
            initialChildSize: 0.42,
            minChildSize: 0.18,
            maxChildSize: 0.75,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: NamaaColors.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const SizedBox(height: NamaaSpacing.sm),
                          // Drag handle
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: NamaaColors.divider,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: NamaaSpacing.md),
                          // Online/offline toggle row
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: NamaaSpacing.md),
                            child: Row(
                              children: [
                                AvatarWidget(
                                  name: driver?.fullName ?? 'السائق',
                                  imageUrl: driver?.avatarUrl,
                                  radius: 24,
                                ),
                                const SizedBox(width: NamaaSpacing.sm),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      driver?.fullName ?? 'السائق',
                                      style: NamaaTypography.labelLarge,
                                    ),
                                    StatusBadge(
                                      status: isOnline
                                          ? DriverStatus.online
                                          : DriverStatus.offline,
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                NamaaToggleButton(
                                  isOnline: isOnline,
                                  onToggle: _toggle,
                                  isLoading: isLoading,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: NamaaSpacing.md),
                          const Divider(height: 1),
                          const SizedBox(height: NamaaSpacing.md),
                          // Earnings + stats
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: NamaaSpacing.md),
                            child: earnings.when(
                              data: (e) => EarningsCard(
                                totalEarnings:
                                    '${e.totalEarnings.toStringAsFixed(0)} ج.س',
                                tripsCount: e.tripsCount,
                                period: e.period,
                              ),
                              loading: () => const SizedBox(
                                height: 100,
                                child: Center(
                                    child: CircularProgressIndicator()),
                              ),
                              error: (_, __) => EarningsCard(
                                totalEarnings: '٠ ج.س',
                                tripsCount: 0,
                                period: 'اليوم',
                              ),
                            ),
                          ),
                          const SizedBox(height: NamaaSpacing.md),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: NamaaSpacing.md),
                            child: Row(
                              children: [
                                Expanded(
                                  child: StatCard(
                                    label: 'رحلات اليوم',
                                    value: earnings
                                            .valueOrNull?.tripsCount
                                            .toString() ??
                                        '٠',
                                    icon: Icons.directions_car,
                                    iconColor: NamaaColors.primary,
                                  ),
                                ),
                                const SizedBox(width: NamaaSpacing.md),
                                Expanded(
                                  child: StatCard(
                                    label: 'التقييم',
                                    value: driver?.rating
                                            .toStringAsFixed(1) ??
                                        '٥.٠',
                                    icon: Icons.star,
                                    iconColor: NamaaColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isOnline) ...[
                            const SizedBox(height: NamaaSpacing.md),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: NamaaSpacing.md),
                              child: Container(
                                padding:
                                    const EdgeInsets.all(NamaaSpacing.md),
                                decoration: BoxDecoration(
                                  color: NamaaColors.background,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: NamaaColors.divider),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      color: NamaaColors.textSecondary,
                                    ),
                                    const SizedBox(width: NamaaSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        'قم بتفعيل الاتصال لاستقبال طلبات الرحلات',
                                        style:
                                            NamaaTypography.bodySmall.copyWith(
                                          color: NamaaColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: NamaaSpacing.xxxl),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
