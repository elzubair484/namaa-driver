import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/sources/support_remote_source.dart';
import '../../domain/entities/ticket_entity.dart';

final supportRemoteSourceProvider = Provider<SupportRemoteSource>((ref) {
  return SupportRemoteSource(ref.watch(supabaseClientProvider));
});

// Ticket list
final ticketsProvider = FutureProvider.autoDispose<List<TicketEntity>>((ref) async {
  final driver = ref.watch(currentDriverProvider).valueOrNull;
  if (driver == null) return [];
  return ref.read(supportRemoteSourceProvider).getTickets(driver.id);
});

// Message stream for a ticket
final messagesProvider =
    StreamProvider.autoDispose.family<List<MessageEntity>, String>(
        (ref, ticketId) {
  return ref.watch(supportRemoteSourceProvider).watchMessages(ticketId);
});

// Create ticket notifier
class CreateTicketNotifier extends AutoDisposeAsyncNotifier<TicketEntity?> {
  @override
  Future<TicketEntity?> build() async => null;

  Future<TicketEntity?> create({
    required TicketCategory category,
    required String subject,
    required String firstMessage,
    String? tripId,
  }) async {
    final driver = ref.read(currentDriverProvider).valueOrNull;
    if (driver == null) return null;

    state = const AsyncLoading();
    TicketEntity? result;
    state = await AsyncValue.guard(() async {
      result = await ref.read(supportRemoteSourceProvider).createTicket(
            driverId: driver.id,
            category: category,
            subject: subject,
            firstMessage: firstMessage,
            tripId: tripId,
          );
      ref.invalidate(ticketsProvider);
      return result;
    });
    return result;
  }
}

final createTicketProvider =
    AutoDisposeAsyncNotifierProvider<CreateTicketNotifier, TicketEntity?>(
        CreateTicketNotifier.new);

// Send message notifier
class SendMessageNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> send(String ticketId, String message) async {
    final driver = ref.read(currentDriverProvider).valueOrNull;
    if (driver == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref
        .read(supportRemoteSourceProvider)
        .sendMessage(
            ticketId: ticketId, senderId: driver.id, message: message));
  }
}

final sendMessageProvider =
    AutoDisposeAsyncNotifierProvider<SendMessageNotifier, void>(
        SendMessageNotifier.new);
