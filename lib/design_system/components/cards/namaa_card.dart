import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radius.dart';
import '../../tokens/shadows.dart';
import '../../tokens/spacing.dart';

class NamaaCard extends StatelessWidget {
  const NamaaCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.onTap,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? (isDark ? NamaaColors.darkSurface : NamaaColors.background),
        borderRadius: borderRadius ?? NamaaRadius.mdAll,
        boxShadow: isDark ? [] : NamaaShadows.card,
        border: isDark
            ? Border.all(color: NamaaColors.darkDivider, width: 1)
            : null,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(NamaaSpacing.md),
        child: child,
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? NamaaRadius.mdAll,
          child: card,
        ),
      );
    }

    return card;
  }
}
