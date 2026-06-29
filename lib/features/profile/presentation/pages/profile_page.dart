import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app.dart';
import '../../../../core/router/route_names.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/components/misc/avatar_widget.dart';
import '../../../../design_system/components/misc/rating_stars.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driver = ref.watch(currentDriverProvider).valueOrNull;
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: NamaaColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(NamaaSpacing.lg),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [NamaaColors.primaryDark, NamaaColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => context.push(RouteNames.editProfile),
                      child: Stack(
                        children: [
                          AvatarWidget(
                            name: driver?.fullName ?? 'السائق',
                            imageUrl: driver?.avatarUrl,
                            radius: 44,
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: NamaaColors.primaryDark,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit,
                                  color: NamaaColors.onPrimary, size: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: NamaaSpacing.sm),
                    Text(
                      driver?.fullName ?? 'السائق',
                      style: NamaaTypography.heading2
                          .copyWith(color: NamaaColors.onPrimary),
                    ),
                    Text(
                      driver?.phone ?? '',
                      style: NamaaTypography.bodySmall.copyWith(
                          color:
                              NamaaColors.onPrimary.withValues(alpha: 0.8)),
                    ),
                    const SizedBox(height: NamaaSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RatingStars(
                            rating: driver?.rating ?? 5.0, size: 20),
                        const SizedBox(width: NamaaSpacing.sm),
                        Text(
                          '${driver?.rating.toStringAsFixed(1) ?? '5.0'} · ${driver?.totalTrips ?? 0} رحلة',
                          style: NamaaTypography.bodySmall.copyWith(
                              color: NamaaColors.onPrimary
                                  .withValues(alpha: 0.9)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: NamaaSpacing.md),

              // Account section
              _Section(
                title: 'الحساب',
                items: [
                  _MenuItem(
                    icon: Icons.person_outline,
                    label: 'تعديل الملف الشخصي',
                    onTap: () => context.push(RouteNames.editProfile),
                  ),
                  _MenuItem(
                    icon: Icons.directions_car_outlined,
                    label: 'معلومات المركبة',
                    onTap: () => context.push(RouteNames.vehicleInfoView),
                  ),
                  _MenuItem(
                    icon: Icons.description_outlined,
                    label: 'المستندات',
                    onTap: () => context.push(RouteNames.documents),
                  ),
                  _MenuItem(
                    icon: Icons.bar_chart,
                    label: 'لوحة الأداء',
                    onTap: () => context.push(RouteNames.performance),
                  ),
                ],
              ),

              const SizedBox(height: NamaaSpacing.sm),

              // Settings section
              _Section(
                title: 'الإعدادات',
                items: [
                  _SwitchMenuItem(
                    icon: Icons.dark_mode_outlined,
                    label: 'الوضع الداكن',
                    value: isDark,
                    onChanged: (v) => ref.read(themeModeProvider.notifier)
                        .setMode(v ? ThemeMode.dark : ThemeMode.light),
                  ),
                  _SwitchMenuItem(
                    icon: Icons.language,
                    label: 'English / عربي',
                    value: !isArabic,
                    onChanged: (v) => ref.read(localeProvider.notifier)
                        .setLocale(v ? const Locale('en') : const Locale('ar')),
                  ),
                  _MenuItem(
                    icon: Icons.support_agent_outlined,
                    label: 'الدعم الفني',
                    onTap: () => context.push(RouteNames.support),
                  ),
                ],
              ),

              const SizedBox(height: NamaaSpacing.sm),

              // Danger section
              _Section(
                title: '',
                items: [
                  _MenuItem(
                    icon: Icons.logout,
                    label: 'تسجيل الخروج',
                    labelColor: NamaaColors.error,
                    iconColor: NamaaColors.error,
                    onTap: () => _confirmLogout(context, ref),
                  ),
                ],
              ),

              const SizedBox(height: NamaaSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await ref.read(authRepositoryProvider).signOut();
            },
            child: Text('خروج',
                style:
                    TextStyle(color: NamaaColors.error)),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.items});
  final String title;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NamaaSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(
                  bottom: NamaaSpacing.sm, right: NamaaSpacing.xs),
              child: Text(title,
                  style: NamaaTypography.labelMedium
                      .copyWith(color: NamaaColors.textSecondary)),
            ),
          ],
          Container(
            decoration: BoxDecoration(
              color: NamaaColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: NamaaColors.divider),
            ),
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  items[i],
                  if (i < items.length - 1)
                    const Divider(height: 1, indent: 52),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.iconColor,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? NamaaColors.primaryDark),
      title: Text(label,
          style: NamaaTypography.bodyMedium
              .copyWith(color: labelColor ?? NamaaColors.textPrimary)),
      trailing: Icon(Icons.chevron_right,
          color: NamaaColors.textSecondary, size: 20),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

class _SwitchMenuItem extends StatelessWidget {
  const _SwitchMenuItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: NamaaColors.primaryDark),
      title: Text(label, style: NamaaTypography.bodyMedium),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: NamaaColors.primaryDark,
      ),
    );
  }
}
