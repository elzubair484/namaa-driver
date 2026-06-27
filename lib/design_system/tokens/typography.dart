import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

abstract final class NamaaTypography {
  static TextStyle get displayLarge => GoogleFonts.manrope(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: NamaaColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get displayMedium => GoogleFonts.manrope(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: NamaaColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get heading1 => GoogleFonts.manrope(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: NamaaColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get heading2 => GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: NamaaColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get heading3 => GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: NamaaColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get bodyLarge => GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: NamaaColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: NamaaColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: NamaaColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get labelLarge => GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: NamaaColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get labelMedium => GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: NamaaColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get labelSmall => GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: NamaaColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get caption => GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: NamaaColors.textSecondary,
        height: 1.4,
      );

  static TextTheme get textTheme => GoogleFonts.manropeTextTheme(
        TextTheme(
          displayLarge: displayLarge,
          displayMedium: displayMedium,
          displaySmall: heading1,
          headlineLarge: heading1,
          headlineMedium: heading2,
          headlineSmall: heading3,
          titleLarge: heading2,
          titleMedium: labelLarge,
          titleSmall: labelMedium,
          bodyLarge: bodyLarge,
          bodyMedium: bodyMedium,
          bodySmall: bodySmall,
          labelLarge: labelLarge,
          labelMedium: labelMedium,
          labelSmall: caption,
        ),
      );
}
