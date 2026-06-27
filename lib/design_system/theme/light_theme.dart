import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';
import '../tokens/radius.dart';

ThemeData buildLightTheme() {
  final colorScheme = const ColorScheme(
    brightness: Brightness.light,
    primary: NamaaColors.primary,
    onPrimary: NamaaColors.onPrimary,
    primaryContainer: NamaaColors.primaryLight,
    onPrimaryContainer: NamaaColors.textPrimary,
    secondary: NamaaColors.onPrimary,
    onSecondary: NamaaColors.primary,
    secondaryContainer: NamaaColors.surface,
    onSecondaryContainer: NamaaColors.textPrimary,
    error: NamaaColors.error,
    onError: Colors.white,
    surface: NamaaColors.surface,
    onSurface: NamaaColors.textPrimary,
    outline: NamaaColors.divider,
    outlineVariant: NamaaColors.textHint,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: NamaaTypography.textTheme,
    // fontFamily set via GoogleFonts.manropeTextTheme
    scaffoldBackgroundColor: NamaaColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: NamaaColors.background,
      foregroundColor: NamaaColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: NamaaTypography.heading2,
      iconTheme: const IconThemeData(color: NamaaColors.textPrimary),
    ),
    cardTheme: CardThemeData(
      color: NamaaColors.background,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: NamaaRadius.mdAll),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: NamaaColors.primary,
        foregroundColor: NamaaColors.onPrimary,
        minimumSize: const Size.fromHeight(52),
        shape: const RoundedRectangleBorder(
          borderRadius: NamaaRadius.mdAll,
        ),
        textStyle: NamaaTypography.labelLarge,
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: NamaaColors.textPrimary,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: NamaaColors.divider),
        shape: const RoundedRectangleBorder(
          borderRadius: NamaaRadius.mdAll,
        ),
        textStyle: NamaaTypography.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: NamaaColors.textPrimary,
        textStyle: NamaaTypography.labelMedium,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: NamaaColors.surface,
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
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: NamaaRadius.mdAll,
        borderSide: const BorderSide(color: NamaaColors.error, width: 2),
      ),
      hintStyle: NamaaTypography.bodyMedium.copyWith(
        color: NamaaColors.textHint,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerTheme: const DividerThemeData(
      color: NamaaColors.divider,
      thickness: 1,
      space: 1,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: NamaaColors.background,
      selectedItemColor: NamaaColors.primary,
      unselectedItemColor: NamaaColors.textHint,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: NamaaRadius.mdAll),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: NamaaRadius.lgAll),
      backgroundColor: NamaaColors.background,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: NamaaColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return NamaaColors.onPrimary;
        return NamaaColors.textHint;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return NamaaColors.primary;
        return NamaaColors.divider;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return NamaaColors.primary;
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(NamaaColors.onPrimary),
      shape: RoundedRectangleBorder(borderRadius: NamaaRadius.smAll),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return NamaaColors.primary;
        return NamaaColors.textHint;
      }),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: NamaaColors.primary,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: NamaaColors.surface,
      selectedColor: NamaaColors.primaryLight,
      labelStyle: NamaaTypography.labelSmall,
      shape: RoundedRectangleBorder(borderRadius: NamaaRadius.fullAll),
    ),
  );
}
