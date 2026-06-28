import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/domain/entities/driver_entity.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/phone_entry_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/onboarding/presentation/pages/profile_setup_page.dart';
import '../../features/onboarding/presentation/pages/vehicle_info_page.dart';
import '../../features/onboarding/presentation/pages/document_upload_page.dart';
import '../../features/onboarding/presentation/pages/pending_approval_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/trips/domain/entities/trip_entity.dart';
import '../../features/trips/presentation/pages/navigating_page.dart';
import '../../features/trips/presentation/pages/passenger_pickup_page.dart';
import '../../features/trips/presentation/pages/active_trip_page.dart';
import '../../features/trips/presentation/pages/trip_completion_page.dart';
import '../../features/trips/presentation/pages/rate_passenger_page.dart';
import '../../features/wallet/presentation/pages/wallet_page.dart';
import '../../features/wallet/presentation/pages/transactions_page.dart';
import '../../features/wallet/presentation/pages/withdrawal_page.dart';
import '../../features/earnings/presentation/pages/earnings_page.dart';
import '../../features/history/presentation/pages/trip_history_page.dart';
import '../../features/history/presentation/pages/trip_detail_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/vehicle_view_page.dart';
import '../../features/profile/presentation/pages/documents_view_page.dart';
import '../../features/support/presentation/pages/support_page.dart';
import '../../features/history/presentation/pages/performance_page.dart';
import '../../features/support/domain/entities/ticket_entity.dart';
import '../../features/support/presentation/pages/ticket_detail_page.dart';
import 'route_names.dart';
import '../../features/notifications/presentation/providers/notification_provider.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ValueNotifier<String?>('loading');

  ref.listen(authSessionProvider, (_, next) {
    authNotifier.value = next.valueOrNull?.user?.id ?? 'unauthenticated';
  });

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    refreshListenable: authNotifier,
    redirect: (context, state) async {
      final loc = state.matchedLocation;

      // Always allow splash to render
      if (loc == RouteNames.splash) return null;

      final session = Supabase.instance.client.auth.currentSession;

      // Not logged in → phone entry
      if (session == null) {
        return loc == RouteNames.phoneEntry ? null : RouteNames.phoneEntry;
      }

      // Logged in + on login page → go to home
      if (loc == RouteNames.phoneEntry) {
        return RouteNames.home; // router will re-redirect based on status
      }

      // Allow onboarding pages freely for authenticated users
      final onboarding = [
        RouteNames.profileSetup,
        RouteNames.vehicleInfo,
        RouteNames.documentUpload,
        RouteNames.pendingApproval,
      ];
      if (onboarding.contains(loc)) return null;

      // For home and main shell — verify driver status
      final driverAsync = ref.read(currentDriverProvider);
      final driver = driverAsync.valueOrNull;

      if (driver == null) {
        // No driver profile yet → start onboarding
        return RouteNames.profileSetup;
      }

      if (driver.status == DriverStatus.pending ||
          driver.status == DriverStatus.underReview ||
          driver.status == DriverStatus.rejected) {
        return RouteNames.pendingApproval;
      }

      if (driver.status == DriverStatus.suspended ||
          driver.status == DriverStatus.inactive) {
        return RouteNames.pendingApproval;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (_, __) => const SplashPage(),
      ),

      // ── Auth ──────────────────────────────────────────────
      GoRoute(
        path: RouteNames.phoneEntry,
        builder: (_, __) => const PhoneEntryPage(),
      ),
      // ── Onboarding ────────────────────────────────────────
      GoRoute(
        path: RouteNames.profileSetup,
        builder: (_, __) => const ProfileSetupPage(),
      ),
      GoRoute(
        path: RouteNames.vehicleInfo,
        builder: (_, __) => const VehicleInfoPage(),
      ),
      GoRoute(
        path: RouteNames.documentUpload,
        builder: (_, __) => const DocumentUploadPage(),
      ),
      GoRoute(
        path: RouteNames.pendingApproval,
        builder: (_, __) => const PendingApprovalPage(),
      ),

      // ── Main shell ────────────────────────────────────────
      ShellRoute(
        builder: (_, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            builder: (_, __) => const HomePage(),
          ),
          GoRoute(
            path: RouteNames.earnings,
            builder: (_, __) => const EarningsPage(),
          ),
          GoRoute(
            path: RouteNames.history,
            builder: (_, __) => const TripHistoryPage(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) =>
                    TripDetailPage(tripId: state.pathParameters['id'] ?? ''),
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.notifications,
            builder: (_, __) => const NotificationsPage(),
          ),
          GoRoute(
            path: RouteNames.profile,
            builder: (_, __) => const ProfilePage(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (_, __) => const EditProfilePage(),
              ),
              GoRoute(
                path: 'vehicle',
                builder: (_, __) => const VehicleViewPage(),
              ),
              GoRoute(
                path: 'documents',
                builder: (_, __) => const DocumentsViewPage(),
              ),
            ],
          ),
        ],
      ),

      // ── Trip execution ─────────────────────────────────────
      GoRoute(
        path: RouteNames.navigatingToPassenger,
        builder: (_, state) =>
            NavigatingPage(trip: state.extra as TripEntity),
      ),
      GoRoute(
        path: RouteNames.passengerPickup,
        builder: (_, state) =>
            PassengerPickupPage(trip: state.extra as TripEntity),
      ),
      GoRoute(
        path: RouteNames.activeTrip,
        builder: (_, state) =>
            ActiveTripPage(trip: state.extra as TripEntity),
      ),
      GoRoute(
        path: RouteNames.tripCompletion,
        builder: (_, state) =>
            TripCompletionPage(trip: state.extra as TripEntity),
      ),
      GoRoute(
        path: RouteNames.ratePassenger,
        builder: (_, state) =>
            RatePassengerPage(trip: state.extra as TripEntity),
      ),

      // ── Other ─────────────────────────────────────────────
      GoRoute(
        path: RouteNames.wallet,
        builder: (_, __) => const WalletPage(),
        routes: [
          GoRoute(
            path: 'transactions',
            builder: (_, __) => const TransactionsPage(),
          ),
          GoRoute(
            path: 'withdrawal',
            builder: (_, __) => const WithdrawalPage(),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.support,
        builder: (_, __) => const SupportPage(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, state) =>
                TicketDetailPage(ticket: state.extra as TicketEntity),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.performance,
        builder: (_, __) => const PerformancePage(),
      ),
    ],
  );
});

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _NamaaBottomNav(),
    );
  }
}

class _NamaaBottomNav extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;
    if (location.startsWith(RouteNames.earnings)) currentIndex = 1;
    if (location.startsWith(RouteNames.history)) currentIndex = 2;
    if (location.startsWith(RouteNames.notifications)) currentIndex = 3;
    if (location.startsWith(RouteNames.profile)) currentIndex = 4;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go(RouteNames.home);
          case 1:
            context.go(RouteNames.earnings);
          case 2:
            context.go(RouteNames.history);
          case 3:
            context.go(RouteNames.notifications);
          case 4:
            context.go(RouteNames.profile);
        }
      },
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_outlined),
          activeIcon: Icon(Icons.account_balance_wallet),
          label: 'الأرباح',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.history_outlined),
          activeIcon: Icon(Icons.history),
          label: 'الرحلات',
        ),
        BottomNavigationBarItem(
          icon: _NotifIcon(ref: ref),
          activeIcon: const Icon(Icons.notifications),
          label: 'الإشعارات',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'حسابي',
        ),
      ],
    );
  }
}

class _NotifIcon extends StatelessWidget {
  const _NotifIcon({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(unreadCountProvider);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_outlined),
        if (count > 0)
          Positioned(
            top: -4,
            left: -4,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                count > 9 ? '9+' : '$count',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}
