import 'package:flutter/material.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

export 'light_theme.dart';
export 'dark_theme.dart';

abstract final class AppTheme {
  static ThemeData get light => buildLightTheme();
  static ThemeData get dark => buildDarkTheme();
}
