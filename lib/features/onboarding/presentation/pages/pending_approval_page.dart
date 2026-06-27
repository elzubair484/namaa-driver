import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/components/buttons/primary_button.dart';
import '../../../../design_system/components/buttons/secondary_button.dart';
import '../../../auth/domain/entities/driver_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class PendingApprovalPage extends ConsumerWidget {
  const PendingApprovalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driverAsync = ref.watch(currentDriverProvider);

    return driverAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: NamaaColors.primary)),
      ),
      error: (_, __) => const _PendingView(status: DriverStatus.pending),
      data: (driver) {
        if (driver == null) return const _PendingView(status: DriverStatus.pending);
        if (driver.status == DriverStatus.rejected) {
          return _RejectedView(reason: driver.rejectionReason);
        }
        if (driver.status == DriverStatus.approved) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => context.go(RouteNames.home),
          );
        }
        return _PendingView(status: driver.status);
      },
    );
  }
}

class _PendingView extends StatelessWidget {
  const _PendingView({required this.status});
  final DriverStatus status;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(NamaaSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: NamaaColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  size: 60,
                  color: NamaaColors.primaryDark,
                ),
              ),
              const SizedBox(height: NamaaSpacing.xl),
              Text(
                'طلبك قيد المراجعة',
                style: NamaaTypography.heading1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: NamaaSpacing.md),
              Text(
                'وثائقك قيد المراجعة من قِبل فريقنا.\nسنخطرك فور الموافقة على طلبك.',
                style: NamaaTypography.bodyLarge
                    .copyWith(color: NamaaColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: NamaaSpacing.xl),
              Container(
                padding: const EdgeInsets.all(NamaaSpacing.md),
                decoration: BoxDecoration(
                  color: NamaaColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NamaaColors.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: NamaaColors.warning, size: 20),
                    const SizedBox(width: NamaaSpacing.sm),
                    Expanded(
                      child: Text(
                        'عادةً ما تستغرق المراجعة من 1-3 أيام عمل',
                        style: NamaaTypography.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: NamaaSpacing.xl),
              Container(
                padding: const EdgeInsets.all(NamaaSpacing.md),
                decoration: BoxDecoration(
                  color: NamaaColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_outlined,
                        color: NamaaColors.primaryDark, size: 20),
                    const SizedBox(width: NamaaSpacing.sm),
                    Expanded(
                      child: Text(
                        'سيصلك إشعار فور الموافقة على حسابك',
                        style: NamaaTypography.bodySmall
                            .copyWith(color: NamaaColors.primaryDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RejectedView extends ConsumerWidget {
  const _RejectedView({this.reason});
  final String? reason;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(NamaaSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: NamaaColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel_outlined,
                  size: 60,
                  color: NamaaColors.error,
                ),
              ),
              const SizedBox(height: NamaaSpacing.xl),
              Text(
                'تم رفض طلبك',
                style: NamaaTypography.heading1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: NamaaSpacing.md),
              Text(
                'نأسف، لم نتمكن من قبول طلبك في الوقت الحالي.',
                style: NamaaTypography.bodyLarge
                    .copyWith(color: NamaaColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              if (reason != null && reason!.isNotEmpty) ...[
                const SizedBox(height: NamaaSpacing.lg),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(NamaaSpacing.md),
                  decoration: BoxDecoration(
                    color: NamaaColors.error.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: NamaaColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'سبب الرفض:',
                        style: NamaaTypography.labelMedium
                            .copyWith(color: NamaaColors.error),
                      ),
                      const SizedBox(height: NamaaSpacing.xs),
                      Text(reason!, style: NamaaTypography.bodyMedium),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: NamaaSpacing.xl),
              PrimaryButton(
                label: 'إعادة التقديم',
                onPressed: () => context.go(RouteNames.profileSetup),
                icon: Icons.refresh,
              ),
              const SizedBox(height: NamaaSpacing.sm),
              SecondaryButton(
                label: 'تسجيل الخروج',
                onPressed: () async {
                  await ref.read(authRepositoryProvider).signOut();
                  if (context.mounted) context.go(RouteNames.phoneEntry);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
