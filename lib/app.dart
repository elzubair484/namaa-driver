import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/storage_keys.dart';
import 'core/di/providers.dart';
import 'core/router/app_router.dart';
import 'core/services/storage_service.dart';
import 'design_system/theme/app_theme.dart';

// ── Theme persistence ─────────────────────────────────────────────────────────

class _ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final storage = ref.read(storageServiceProvider);
    final saved = storage.getString(StorageKeys.themeMode);
    return switch (saved) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  void setMode(ThemeMode mode) {
    state = mode;
    final storage = ref.read(storageServiceProvider);
    storage.setString(StorageKeys.themeMode, switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      _ => 'system',
    });
  }
}

final themeModeProvider =
    NotifierProvider<_ThemeModeNotifier, ThemeMode>(_ThemeModeNotifier.new);

// ── Locale persistence ────────────────────────────────────────────────────────

class _LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final storage = ref.read(storageServiceProvider);
    final saved = storage.getString(StorageKeys.locale);
    return Locale(saved ?? 'ar');
  }

  void setLocale(Locale locale) {
    state = locale;
    ref.read(storageServiceProvider).setString(StorageKeys.locale, locale.languageCode);
  }
}

final localeProvider =
    NotifierProvider<_LocaleNotifier, Locale>(_LocaleNotifier.new);

// ── App ───────────────────────────────────────────────────────────────────────

class NamaaDriverApp extends ConsumerWidget {
  const NamaaDriverApp({super.key, required this.storageService});
  final StorageService storageService;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'نماء للسائقين',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) {
        return Directionality(
          textDirection: locale.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child!,
        );
      },
    );
  }
}
