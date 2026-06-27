import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/typography.dart';
import '../../tokens/radius.dart';
import '../../tokens/durations.dart';

class NamaaToggleButton extends StatelessWidget {
  const NamaaToggleButton({
    super.key,
    required this.isOnline,
    required this.onToggle,
    this.isLoading = false,
  });

  final bool isOnline;
  final VoidCallback onToggle;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onToggle,
      child: AnimatedContainer(
        duration: NamaaDurations.medium,
        width: 140,
        height: 52,
        decoration: BoxDecoration(
          color: isOnline ? NamaaColors.onlineGreen : NamaaColors.offlineGrey,
          borderRadius: NamaaRadius.fullAll,
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: NamaaDurations.medium,
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isOnline ? 'متصل' : 'غير متصل',
                    style: NamaaTypography.labelMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
