import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radius.dart';

class NamaaIconButton extends StatelessWidget {
  const NamaaIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 44,
    this.backgroundColor,
    this.iconColor,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final btn = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? NamaaColors.surface,
        borderRadius: NamaaRadius.mdAll,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: iconColor ?? NamaaColors.textPrimary,
          size: size * 0.45,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: btn);
    }
    return btn;
  }
}
