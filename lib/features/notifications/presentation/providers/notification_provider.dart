import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/sources/notification_remote_source.dart';
import '../../domain/entities/notification_entity.dart';

final notificationRemoteSourceProvider =
    Provider<NotificationRemoteSource>((ref) {
  return NotificationRemoteSource(ref.watch(supabaseClientProvider));
});

final notificationsProvider =
    StreamProvider<List<NotificationEntity>>((ref) {
  final driver = ref.watch(currentDriverProvider).valueOrNull;
  if (driver == null) return Stream.value([]);
  return ref
      .watch(notificationRemoteSourceProvider)
      .watchNotifications(driver.id);
});

final unreadCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider).valueOrNull ?? [];
  return notifications.where((n) => !n.isRead).length;
});

class NotificationActionsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> markRead(String id) async {
    await ref.read(notificationRemoteSourceProvider).markRead(id);
  }

  Future<void> markAllRead() async {
    final driver = ref.read(currentDriverProvider).valueOrNull;
    if (driver == null) return;
    await ref.read(notificationRemoteSourceProvider).markAllRead(driver.id);
  }
}

final notificationActionsProvider =
    AsyncNotifierProvider<NotificationActionsNotifier, void>(
        NotificationActionsNotifier.new);
