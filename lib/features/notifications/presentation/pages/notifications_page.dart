import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/components/feedback/empty_state.dart';
import '../../../../design_system/components/feedback/error_state.dart';
import '../../domain/entities/notification_entity.dart';
import '../providers/notification_provider.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifAsync = ref.watch(notificationsProvider);
    final unread = ref.watch(unreadCountProvider);

    return Scaffold(
      backgroundColor: NamaaColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  NamaaSpacing.md, NamaaSpacing.md, NamaaSpacing.md, 0),
              child: Row(
                children: [
                  Text('الإشعارات', style: NamaaTypography.heading1),
                  if (unread > 0) ...[
                    const SizedBox(width: NamaaSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: NamaaSpacing.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: NamaaColors.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$unread',
                        style: NamaaTypography.caption
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (unread > 0)
                    TextButton(
                      onPressed: () => ref
                          .read(notificationActionsProvider.notifier)
                          .markAllRead(),
                      child: Text('تعليم الكل مقروءاً',
                          style: NamaaTypography.labelMedium
                              .copyWith(color: NamaaColors.primaryDark)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: NamaaSpacing.sm),
            Expanded(
              child: notifAsync.when(
                data: (list) => list.isEmpty
                    ? const EmptyState(
                        title: 'لا توجد إشعارات',
                        icon: Icons.notifications_none,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: NamaaSpacing.md),
                        itemCount: list.length,
                        itemBuilder: (_, i) => _NotifTile(
                          notif: list[i],
                          onTap: () => ref
                              .read(notificationActionsProvider.notifier)
                              .markRead(list[i].id),
                        ),
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => ErrorState(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(notificationsProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.notif, required this.onTap});
  final NotificationEntity notif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = !notif.isRead;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: NamaaSpacing.sm),
        padding: const EdgeInsets.all(NamaaSpacing.md),
        decoration: BoxDecoration(
          color: unread
              ? NamaaColors.primaryLight
              : NamaaColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: unread ? NamaaColors.primary : NamaaColors.divider,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(NamaaSpacing.sm),
              decoration: BoxDecoration(
                color: _iconBg(notif.type),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon(notif.type),
                  color: _iconColor(notif.type), size: 20),
            ),
            const SizedBox(width: NamaaSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.titleAr,
                          style: unread
                              ? NamaaTypography.labelLarge
                              : NamaaTypography.labelMedium,
                        ),
                      ),
                      if (unread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: NamaaColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.bodyAr,
                    style: NamaaTypography.bodySmall
                        .copyWith(color: NamaaColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeAgo(notif.createdAt),
                    style: NamaaTypography.caption
                        .copyWith(color: NamaaColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _icon(NotificationType t) => switch (t) {
        NotificationType.tripRequest => Icons.directions_car,
        NotificationType.tripUpdate => Icons.update,
        NotificationType.payment => Icons.attach_money,
        NotificationType.document => Icons.description,
        NotificationType.support => Icons.support_agent,
        NotificationType.system => Icons.info,
      };

  Color _iconColor(NotificationType t) => switch (t) {
        NotificationType.tripRequest => NamaaColors.primaryDark,
        NotificationType.payment => NamaaColors.onlineGreen,
        NotificationType.document => NamaaColors.error,
        NotificationType.support => NamaaColors.primaryDark,
        _ => NamaaColors.textSecondary,
      };

  Color _iconBg(NotificationType t) => switch (t) {
        NotificationType.tripRequest => NamaaColors.primaryLight,
        NotificationType.payment =>
          NamaaColors.onlineGreen.withValues(alpha: 0.1),
        NotificationType.document =>
          NamaaColors.error.withValues(alpha: 0.1),
        _ => NamaaColors.background,
      };

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }
}
