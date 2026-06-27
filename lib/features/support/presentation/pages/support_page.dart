import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/components/buttons/primary_button.dart';
import '../../../../design_system/components/feedback/empty_state.dart';
import '../../../../design_system/components/feedback/error_state.dart';
import '../../../../design_system/components/feedback/loading_state.dart';
import '../../domain/entities/ticket_entity.dart';
import '../providers/support_provider.dart';

class SupportPage extends ConsumerWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(ticketsProvider);

    return Scaffold(
      backgroundColor: NamaaColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(NamaaSpacing.md),
              child: Row(
                children: [
                  Text('الدعم الفني', style: NamaaTypography.heading1),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => _showNewTicketSheet(context, ref),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('تذكرة جديدة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NamaaColors.primary,
                      foregroundColor: NamaaColors.onPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ticketsAsync.when(
                data: (list) => list.isEmpty
                    ? const EmptyState(
                        title: 'لا توجد تذاكر دعم',
                        icon: Icons.support_agent_outlined,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: NamaaSpacing.md),
                        itemCount: list.length,
                        itemBuilder: (_, i) => _TicketTile(
                          ticket: list[i],
                          onTap: () => context.push(
                              '/support/${list[i].id}',
                              extra: list[i]),
                        ),
                      ),
                loading: () => const LoadingState(),
                error: (e, _) => ErrorState(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(ticketsProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewTicketSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _NewTicketSheet(onCreated: (ticket) {
        Navigator.pop(context);
        ref.invalidate(ticketsProvider);
        context.push('/support/${ticket.id}', extra: ticket);
      }),
    );
  }
}

class _TicketTile extends StatelessWidget {
  const _TicketTile({required this.ticket, required this.onTap});
  final TicketEntity ticket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (ticket.status) {
      TicketStatus.open => NamaaColors.primary,
      TicketStatus.inProgress => NamaaColors.primaryDark,
      TicketStatus.resolved => NamaaColors.onlineGreen,
      TicketStatus.closed => NamaaColors.textSecondary,
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: NamaaSpacing.sm),
        padding: const EdgeInsets.all(NamaaSpacing.md),
        decoration: BoxDecoration(
          color: NamaaColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: NamaaColors.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(NamaaSpacing.sm),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.support_agent, color: statusColor, size: 20),
            ),
            const SizedBox(width: NamaaSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ticket.subject,
                      style: NamaaTypography.labelMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(ticket.category.labelAr,
                      style: NamaaTypography.caption
                          .copyWith(color: NamaaColors.textSecondary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: NamaaSpacing.sm, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(ticket.status.labelAr,
                  style:
                      NamaaTypography.caption.copyWith(color: statusColor)),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewTicketSheet extends ConsumerStatefulWidget {
  const _NewTicketSheet({required this.onCreated});
  final void Function(TicketEntity) onCreated;

  @override
  ConsumerState<_NewTicketSheet> createState() => _NewTicketSheetState();
}

class _NewTicketSheetState extends ConsumerState<_NewTicketSheet> {
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  TicketCategory _category = TicketCategory.other;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_subjectCtrl.text.trim().isEmpty ||
        _messageCtrl.text.trim().isEmpty) return;

    final ticket = await ref.read(createTicketProvider.notifier).create(
          category: _category,
          subject: _subjectCtrl.text.trim(),
          firstMessage: _messageCtrl.text.trim(),
        );
    if (ticket != null && mounted) widget.onCreated(ticket);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(createTicketProvider).isLoading;

    return Padding(
      padding: EdgeInsets.fromLTRB(NamaaSpacing.md, NamaaSpacing.md,
          NamaaSpacing.md, MediaQuery.of(context).viewInsets.bottom + NamaaSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: NamaaColors.divider,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: NamaaSpacing.md),
          Text('تذكرة دعم جديدة', style: NamaaTypography.heading2),
          const SizedBox(height: NamaaSpacing.md),
          // Category picker
          DropdownButtonFormField<TicketCategory>(
            value: _category,
            decoration: InputDecoration(
              labelText: 'التصنيف',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: NamaaColors.surface,
            ),
            items: TicketCategory.values
                .map((c) => DropdownMenuItem(
                    value: c, child: Text(c.labelAr)))
                .toList(),
            onChanged: (v) => setState(() => _category = v!),
          ),
          const SizedBox(height: NamaaSpacing.md),
          TextFormField(
            controller: _subjectCtrl,
            decoration: InputDecoration(
              labelText: 'الموضوع',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: NamaaColors.surface,
            ),
          ),
          const SizedBox(height: NamaaSpacing.md),
          TextFormField(
            controller: _messageCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'وصف المشكلة',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: NamaaColors.surface,
            ),
          ),
          const SizedBox(height: NamaaSpacing.md),
          PrimaryButton(
            label: 'إرسال التذكرة',
            isLoading: isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
