import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/components/misc/namaa_app_bar.dart';
import '../../../../design_system/components/feedback/error_state.dart';
import '../../domain/entities/ticket_entity.dart';
import '../providers/support_provider.dart';

class TicketDetailPage extends ConsumerStatefulWidget {
  const TicketDetailPage({super.key, required this.ticket});
  final TicketEntity ticket;

  @override
  ConsumerState<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends ConsumerState<TicketDetailPage> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();
    await ref
        .read(sendMessageProvider.notifier)
        .send(widget.ticket.id, text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.ticket.id));
    final isClosed = widget.ticket.status == TicketStatus.closed ||
        widget.ticket.status == TicketStatus.resolved;
    final currentUserId =
        Supabase.instance.client.auth.currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: NamaaColors.background,
      appBar: NamaaAppBar(
        title: widget.ticket.subject,
        actions: [
          Container(
            margin: const EdgeInsets.only(left: NamaaSpacing.md),
            padding: const EdgeInsets.symmetric(
                horizontal: NamaaSpacing.sm, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor(widget.ticket.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.ticket.status.labelAr,
              style: NamaaTypography.caption.copyWith(
                  color: _statusColor(widget.ticket.status)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category chip
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: NamaaSpacing.md, vertical: NamaaSpacing.sm),
            color: NamaaColors.surface,
            child: Row(
              children: [
                const Icon(Icons.label_outline,
                    size: 16, color: NamaaColors.textSecondary),
                const SizedBox(width: NamaaSpacing.xs),
                Text(widget.ticket.category.labelAr,
                    style: NamaaTypography.bodySmall
                        .copyWith(color: NamaaColors.textSecondary)),
              ],
            ),
          ),
          const Divider(height: 1),
          // Messages
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                _scrollToBottom();
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(NamaaSpacing.md),
                  itemCount: messages.length,
                  itemBuilder: (_, i) => _MessageBubble(
                    msg: messages[i],
                    isOwn: messages[i].senderId == currentUserId,
                  ),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorState(
                message: e.toString(),
                onRetry: () => ref.invalidate(messagesProvider(widget.ticket.id)),
              ),
            ),
          ),
          // Input bar
          if (!isClosed)
            Container(
              padding: EdgeInsets.fromLTRB(
                NamaaSpacing.md,
                NamaaSpacing.sm,
                NamaaSpacing.md,
                MediaQuery.of(context).viewInsets.bottom + NamaaSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: NamaaColors.surface,
                border: const Border(
                    top: BorderSide(color: NamaaColors.divider)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالتك...',
                        hintStyle: NamaaTypography.bodyMedium
                            .copyWith(color: NamaaColors.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide:
                              const BorderSide(color: NamaaColors.divider),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: NamaaSpacing.md,
                            vertical: NamaaSpacing.sm),
                        filled: true,
                        fillColor: NamaaColors.background,
                      ),
                      maxLines: 3,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: NamaaSpacing.sm),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      padding: const EdgeInsets.all(NamaaSpacing.md),
                      decoration: const BoxDecoration(
                        color: NamaaColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send,
                          color: NamaaColors.onPrimary, size: 20),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(NamaaSpacing.md),
              color: NamaaColors.surface,
              child: Text(
                'هذه التذكرة ${widget.ticket.status.labelAr}',
                textAlign: TextAlign.center,
                style: NamaaTypography.bodySmall
                    .copyWith(color: NamaaColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }

  Color _statusColor(TicketStatus s) => switch (s) {
        TicketStatus.open => NamaaColors.primary,
        TicketStatus.inProgress => NamaaColors.primaryDark,
        TicketStatus.resolved => NamaaColors.onlineGreen,
        TicketStatus.closed => NamaaColors.textSecondary,
      };
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.msg, required this.isOwn});
  final MessageEntity msg;
  final bool isOwn;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: NamaaSpacing.sm),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: NamaaSpacing.md, vertical: NamaaSpacing.sm),
        decoration: BoxDecoration(
          color: isOwn ? NamaaColors.primary : NamaaColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isOwn ? 16 : 4),
            bottomRight: Radius.circular(isOwn ? 4 : 16),
          ),
          border: isOwn
              ? null
              : Border.all(color: NamaaColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isOwn)
              Text(
                'فريق الدعم',
                style: NamaaTypography.caption.copyWith(
                    color: NamaaColors.primaryDark,
                    fontWeight: FontWeight.bold),
              ),
            Text(
              msg.message,
              style: NamaaTypography.bodyMedium.copyWith(
                color: isOwn ? NamaaColors.onPrimary : NamaaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${msg.createdAt.hour.toString().padLeft(2, '0')}:${msg.createdAt.minute.toString().padLeft(2, '0')}',
              style: NamaaTypography.caption.copyWith(
                color: isOwn
                    ? NamaaColors.onPrimary.withValues(alpha: 0.7)
                    : NamaaColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
