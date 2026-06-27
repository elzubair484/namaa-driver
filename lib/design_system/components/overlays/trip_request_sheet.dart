import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/typography.dart';
import '../../tokens/spacing.dart';
import '../../tokens/radius.dart';
import '../buttons/primary_button.dart';
import '../buttons/secondary_button.dart';
import '../misc/rating_stars.dart';

class TripRequestSheet extends StatefulWidget {
  const TripRequestSheet({
    super.key,
    required this.passengerName,
    required this.passengerRating,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.pickupDistance,
    required this.estimatedFare,
    required this.timeoutSeconds,
    required this.onAccept,
    required this.onReject,
  });

  final String passengerName;
  final double passengerRating;
  final String pickupAddress;
  final String dropoffAddress;
  final String pickupDistance;
  final String estimatedFare;
  final int timeoutSeconds;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  State<TripRequestSheet> createState() => _TripRequestSheetState();
}

class _TripRequestSheetState extends State<TripRequestSheet>
    with SingleTickerProviderStateMixin {
  late int _remaining;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _remaining = widget.timeoutSeconds;
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.timeoutSeconds),
    )..forward();

    Stream.periodic(const Duration(seconds: 1)).take(widget.timeoutSeconds).listen(
      (_) {
        if (mounted) {
          setState(() => _remaining--);
          if (_remaining <= 0) widget.onReject();
        }
      },
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + NamaaSpacing.lg,
        top: NamaaSpacing.md,
        left: NamaaSpacing.lg,
        right: NamaaSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: NamaaColors.divider,
              borderRadius: NamaaRadius.fullAll,
            ),
          ),
          const SizedBox(height: NamaaSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('طلب رحلة جديد', style: NamaaTypography.heading3),
              _CountdownTimer(remaining: _remaining, total: widget.timeoutSeconds),
            ],
          ),
          const SizedBox(height: NamaaSpacing.md),
          AnimatedBuilder(
            animation: _progressController,
            builder: (_, __) => LinearProgressIndicator(
              value: 1 - _progressController.value,
              backgroundColor: NamaaColors.divider,
              color: _remaining <= 5 ? NamaaColors.error : NamaaColors.primary,
              borderRadius: NamaaRadius.fullAll,
            ),
          ),
          const SizedBox(height: NamaaSpacing.md),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: NamaaColors.primaryLight,
                child: Text(
                  widget.passengerName.isNotEmpty
                      ? widget.passengerName[0]
                      : '?',
                  style: NamaaTypography.heading3,
                ),
              ),
              const SizedBox(width: NamaaSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.passengerName, style: NamaaTypography.labelLarge),
                  RatingStars(rating: widget.passengerRating, size: 14),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(widget.estimatedFare,
                      style: NamaaTypography.heading2.copyWith(
                        color: NamaaColors.primary,
                      )),
                  Text('تقديري', style: NamaaTypography.caption),
                ],
              ),
            ],
          ),
          const SizedBox(height: NamaaSpacing.md),
          Container(
            padding: const EdgeInsets.all(NamaaSpacing.md),
            decoration: BoxDecoration(
              color: NamaaColors.surface,
              borderRadius: NamaaRadius.mdAll,
            ),
            child: Column(
              children: [
                _LocationRow(
                  icon: Icons.radio_button_checked,
                  iconColor: NamaaColors.onlineGreen,
                  label: 'نقطة الالتقاء',
                  address: widget.pickupAddress,
                  trailing: widget.pickupDistance,
                ),
                const SizedBox(height: NamaaSpacing.sm),
                const Divider(height: 1),
                const SizedBox(height: NamaaSpacing.sm),
                _LocationRow(
                  icon: Icons.location_on,
                  iconColor: NamaaColors.error,
                  label: 'الوجهة',
                  address: widget.dropoffAddress,
                ),
              ],
            ),
          ),
          const SizedBox(height: NamaaSpacing.md),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'رفض',
                  onPressed: widget.onReject,
                ),
              ),
              const SizedBox(width: NamaaSpacing.md),
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label: 'قبول الرحلة',
                  onPressed: widget.onAccept,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountdownTimer extends StatelessWidget {
  const _CountdownTimer({required this.remaining, required this.total});
  final int remaining;
  final int total;

  @override
  Widget build(BuildContext context) {
    final isUrgent = remaining <= 5;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isUrgent
            ? NamaaColors.error.withValues(alpha: 0.12)
            : NamaaColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$remaining',
          style: NamaaTypography.heading3.copyWith(
            color: isUrgent ? NamaaColors.error : NamaaColors.primaryDark,
          ),
        ),
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.address,
    this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String address;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: NamaaSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: NamaaTypography.caption),
              Text(
                address,
                style: NamaaTypography.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: NamaaSpacing.sm),
          Text(
            trailing!,
            style: NamaaTypography.labelSmall.copyWith(
              color: NamaaColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
