import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/typography.dart';
import '../../tokens/spacing.dart';
import 'namaa_card.dart';

class TripCard extends StatelessWidget {
  const TripCard({
    super.key,
    required this.tripId,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.fare,
    required this.date,
    this.status,
    this.passengerRating,
    this.onTap,
  });

  final String tripId;
  final String pickupAddress;
  final String dropoffAddress;
  final String fare;
  final String date;
  final String? status;
  final double? passengerRating;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return NamaaCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: NamaaTypography.caption,
              ),
              Text(
                fare,
                style: NamaaTypography.heading3.copyWith(
                  color: NamaaColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: NamaaSpacing.sm),
          _LocationRow(
            icon: Icons.radio_button_checked,
            iconColor: NamaaColors.onlineGreen,
            address: pickupAddress,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 9),
            child: SizedBox(
              height: 12,
              child: VerticalDivider(width: 1),
            ),
          ),
          _LocationRow(
            icon: Icons.location_on,
            iconColor: NamaaColors.error,
            address: dropoffAddress,
          ),
          if (status != null || passengerRating != null) ...[
            const SizedBox(height: NamaaSpacing.sm),
            Row(
              children: [
                if (status != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: NamaaColors.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(status!, style: NamaaTypography.labelSmall),
                  ),
                const Spacer(),
                if (passengerRating != null) ...[
                  const Icon(Icons.star, size: 14, color: NamaaColors.primary),
                  const SizedBox(width: 2),
                  Text(
                    passengerRating!.toStringAsFixed(1),
                    style: NamaaTypography.labelSmall,
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.icon,
    required this.iconColor,
    required this.address,
  });

  final IconData icon;
  final Color iconColor;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: NamaaSpacing.sm),
        Expanded(
          child: Text(
            address,
            style: NamaaTypography.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
