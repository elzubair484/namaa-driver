import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/typography.dart';

enum DriverStatus { online, offline, onTrip, pending }

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});
  final DriverStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _bgColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _label,
            style: NamaaTypography.labelSmall.copyWith(color: _bgColor),
          ),
        ],
      ),
    );
  }

  Color get _bgColor {
    return switch (status) {
      DriverStatus.online => NamaaColors.onlineGreen,
      DriverStatus.offline => NamaaColors.offlineGrey,
      DriverStatus.onTrip => NamaaColors.primary,
      DriverStatus.pending => NamaaColors.warning,
    };
  }

  String get _label {
    return switch (status) {
      DriverStatus.online => 'متصل',
      DriverStatus.offline => 'غير متصل',
      DriverStatus.onTrip => 'في رحلة',
      DriverStatus.pending => 'قيد المراجعة',
    };
  }
}
