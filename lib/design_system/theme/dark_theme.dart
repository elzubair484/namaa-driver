import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';
import '../tokens/radius.dart';

ThemeData buildDarkTheme() {
  final colorScheme = const ColorScheme(
    brightness: Brightness.dark,
    primary: NamaaColors.primary,
    onPrimary: NamaaColors.onPrimary,
    primaryContainer: Color(0xFF3D3000),
    onPrimaryContainer: NamaaColors.primaryLight,
    secondary: NamaaColors.primary,
    onSecondary: NamaaColors.onPrimary,
    secondaryContainer: NamaaColors.darkSurface2,
    onSecondaryContainer: NamaaColors.darkTextPrimary,
    error: NamaaColors.error,
    onError: Colors.white,
    surface: NamaaColors.darkSurface,
    onSurface: NamaaColors.darkTextPrimary,
    outline: NamaaColors.darkDivider,
    outlineVariant: Color(0xFF444444),
  );

  final darkTextTheme = NamaaTypography.textTheme.apply(
    bodyColor: NamaaColors.darkTextPrimary,
    displayColor: NamaaColors.darkTextPrimary,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: darkTextTheme,
    // fontFamily set via GoogleFonts.manropeTextTheme
    scaffoldBackgroundColor: NamaaColors.darkBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: NamaaColors.darkBackground,
      foregroundColor: NamaaColors.darkTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: NamaaTypography.heading2.copyWith(
        color: NamaaColors.darkTextPrimary,
      ),
      iconTheme: const IconThemeData(color: NamaaColors.darkTextPrimary),
    ),
    cardTheme: CardThemeData(
      color: NamaaColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: NamaaRadius.mdAll),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: NamaaColors.primary,
        foregroundColor: NamaaColors.onPrimary,
        minimumSize: const Size.fromHeight(52),
        shape: const RoundedRectangleBorder(borderRadius: NamaaRadius.mdAll),
        textStyle: NamaaTypography.labelLarge,
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: NamaaColors.darkTextPrimary,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: NamaaColors.darkDivider),
        shape: const RoundedRectangleBorder(borderRadius: NamaaRadius.mdAll),
        textStyle: NamaaTypography.labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: NamaaColors.darkSurface2,
      border: OutlineInputBorder(
        borderRadius: NamaaRadius.mdAll,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: NamaaRadius.mdAll,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: NamaaRadius.mdAll,
        borderSide: const BorderSide(color: NamaaColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: NamaaRadius.mdAll,
        borderSide: const BorderSide(color: NamaaColors.error, width: 1),
      ),
      hintStyle: NamaaTypography.bodyMedium.copyWith(
        color: NamaaColors.darkTextSecondary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerTheme: const DividerThemeData(
      color: NamaaColors.darkDivider,
      thickness: 1,
      space: 1,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: NamaaColors.darkSurface,
      selectedItemColor: NamaaColors.primary,
      unselectedItemColor: NamaaColors.darkTextSecondary,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: NamaaColors.darkSurface2,
      contentTextStyle: NamaaTypography.bodyMedium.copyWith(
        color: NamaaColors.darkTextPrimary,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: NamaaRadius.mdAll),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: NamaaRadius.lgAll),
      backgroundColor: NamaaColors.darkSurface,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: NamaaColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return NamaaColors.onPrimary;
        return NamaaColors.darkTextSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return NamaaColors.primary;
        return NamaaColors.darkDivider;
      }),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: NamaaColors.primary,
    ),
  );
}
