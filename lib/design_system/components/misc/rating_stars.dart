import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/typography.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.showLabel = true,
    this.starCount = 5,
  });

  final double rating;
  final double size;
  final bool showLabel;
  final int starCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(starCount, (i) {
          final filled = i < rating.floor();
          final partial = !filled && i < rating;
          return Icon(
            filled
                ? Icons.star
                : partial
                    ? Icons.star_half
                    : Icons.star_border,
            size: size,
            color: NamaaColors.primary,
          );
        }),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: NamaaTypography.labelSmall.copyWith(
              color: NamaaColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
