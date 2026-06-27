import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/components/buttons/primary_button.dart';
import '../../domain/entities/trip_entity.dart';
import '../providers/trip_provider.dart';

class RatePassengerPage extends ConsumerStatefulWidget {
  const RatePassengerPage({super.key, required this.trip});
  final TripEntity trip;

  @override
  ConsumerState<RatePassengerPage> createState() => _RatePassengerPageState();
}

class _RatePassengerPageState extends ConsumerState<RatePassengerPage> {
  int _rating = 5;
  bool _submitting = false;

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await ref
        .read(tripActionsProvider.notifier)
        .ratePassenger(widget.trip.id, _rating);
    if (!mounted) return;
    context.go(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NamaaColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(NamaaSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const CircleAvatar(
                radius: 48,
                backgroundColor: NamaaColors.primaryLight,
                child: Icon(Icons.person,
                    size: 56, color: NamaaColors.primaryDark),
              ),
              const SizedBox(height: NamaaSpacing.md),
              Text(
                'كيف كان الراكب؟',
                textAlign: TextAlign.center,
                style: NamaaTypography.heading1,
              ),
              Text(
                widget.trip.passengerName ?? 'الراكب',
                textAlign: TextAlign.center,
                style: NamaaTypography.bodyLarge
                    .copyWith(color: NamaaColors.textSecondary),
              ),
              const SizedBox(height: NamaaSpacing.xl),
              // Star selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final filled = i < _rating;
                  return GestureDetector(
                    onTap: () => setState(() => _rating = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: NamaaSpacing.sm),
                      child: Icon(
                        filled ? Icons.star : Icons.star_border,
                        size: 48,
                        color: filled
                            ? NamaaColors.primary
                            : NamaaColors.divider,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: NamaaSpacing.sm),
              Text(
                _ratingLabel(_rating),
                textAlign: TextAlign.center,
                style: NamaaTypography.labelLarge
                    .copyWith(color: NamaaColors.primaryDark),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'إرسال التقييم',
                isLoading: _submitting,
                onPressed: _submit,
              ),
              const SizedBox(height: NamaaSpacing.md),
              TextButton(
                onPressed: () => context.go(RouteNames.home),
                child: const Text('تخطي'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _ratingLabel(int r) => switch (r) {
        1 => 'سيء جداً',
        2 => 'سيء',
        3 => 'مقبول',
        4 => 'جيد',
        _ => 'ممتاز',
      };
}
