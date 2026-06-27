import 'package:logger/logger.dart';

final appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

abstract final class AppLogger {
  static void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      appLogger.d(message, error: error, stackTrace: stackTrace);

  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      appLogger.i(message, error: error, stackTrace: stackTrace);

  static void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      appLogger.w(message, error: error, stackTrace: stackTrace);

  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      appLogger.e(message, error: error, stackTrace: stackTrace);
}
