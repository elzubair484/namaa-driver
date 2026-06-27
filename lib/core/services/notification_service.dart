import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

/// Callback invoked when user taps a notification — provides the data payload.
typedef NotificationTapCallback = void Function(Map<String, dynamic> data);

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  NotificationTapCallback? onTap;

  static const _androidChannel = AndroidNotificationChannel(
    'namaa_driver_high',
    'Namaa Driver Alerts',
    description: 'Trip requests and important alerts',
    importance: Importance.max,
  );

  Future<void> init() async {
    await _requestPermissions();
    await _setupLocalNotifications();
    _listenForeground();
    _listenNotificationOpen();
    await _checkInitialMessage();
  }

  Future<void> _requestPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );
  }

  Future<void> _setupLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
  }

  // Foreground: show local notification banner
  void _listenForeground() {
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;

      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(presentAlert: true),
        ),
        payload: message.data.entries.map((e) => '${e.key}=${e.value}').join('&'),
      );
    });
  }

  // Background → foreground: app was in background, user tapped notification
  void _listenNotificationOpen() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      onTap?.call(message.data);
    });
  }

  // Terminated → foreground: app was closed, user tapped notification
  Future<void> _checkInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message != null) {
      // Delay so router is ready before navigating
      Future.delayed(const Duration(milliseconds: 500), () {
        onTap?.call(message.data);
      });
    }
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;
    // Parse key=value&key=value payload back to map
    final data = Map.fromEntries(
      payload.split('&').where((s) => s.contains('=')).map((s) {
        final parts = s.split('=');
        return MapEntry(parts[0], parts.skip(1).join('='));
      }),
    );
    onTap?.call(data);
  }

  /// Save (or refresh) the FCM token in the `drivers` table.
  Future<void> saveToken(String driverId) async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;

      await Supabase.instance.client
          .from('drivers')
          .update({'fcm_token': token})
          .eq('id', driverId);

      AppLogger.info('FCM token saved for driver $driverId');

      // Refresh token when it rotates
      _messaging.onTokenRefresh.listen((newToken) async {
        await Supabase.instance.client
            .from('drivers')
            .update({'fcm_token': newToken})
            .eq('id', driverId);
      });
    } catch (e) {
      AppLogger.error('Failed to save FCM token', e);
    }
  }

  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      AppLogger.error('Failed to get FCM token', e);
      return null;
    }
  }

  Future<void> deleteToken() => _messaging.deleteToken();
}
