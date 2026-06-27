import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/typography.dart';

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 24,
    this.onTap,
  });

  final String? imageUrl;
  final String? name;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget avatar;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatar = CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(imageUrl!),
        backgroundColor: NamaaColors.primaryLight,
      );
    } else {
      final initials = _initials(name);
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: NamaaColors.primaryLight,
        child: Text(
          initials,
          style: NamaaTypography.heading3.copyWith(
            fontSize: radius * 0.7,
            color: NamaaColors.primaryDark,
          ),
        ),
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }
    return avatar;
  }

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
