import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';
import 'auth_service.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await PushNotificationService.handleBackgroundMessage(message);
}

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    if (kIsWeb) {
      debugPrint('[PushNotifications] Skipping initialization on web builds.');
      return;
    }

    await _ensurePermissions();
    await _syncInitialToken();
    await _logInitialMessage();

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(
      _handleNotificationInteraction,
    );

    _messaging.onTokenRefresh.listen((token) async {
      debugPrint('[PushNotifications] FCM token refreshed: $token');
      await AuthService.saveDeviceToken(token);
      final storedToken = await AuthService.getDeviceToken();
      debugPrint('[PushNotifications] AuthService stored token: $storedToken');
    });
  }

  static Future<void> _ensurePermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    debugPrint('[PushNotifications] Notification permission status: '
      '${settings.authorizationStatus}');
  }

  static Future<void> _syncInitialToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        debugPrint('[PushNotifications] Current FCM token: $token');
        await AuthService.saveDeviceToken(token);
        final storedToken = await AuthService.getDeviceToken();
        debugPrint('[PushNotifications] AuthService stored token: $storedToken');
      } else {
        debugPrint('[PushNotifications] FCM token is null; waiting for refresh callback.');
      }
    } catch (e) {
      debugPrint('[PushNotifications] Error retrieving FCM token: $e');
    }
  }

  static Future<void> _logInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message != null) {
      _logMessageDetails('initial-open', message);
    }
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    _logMessageDetails('foreground', message);
  }

  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    _logMessageDetails('background', message);
  }

  static void _handleNotificationInteraction(RemoteMessage message) {
    _logMessageDetails('opened-app', message);
  }

  static void _logMessageDetails(String context, RemoteMessage message) {
    final notification = message.notification;
    final title = notification?.title ?? '(no title)';
    final body = notification?.body ?? '(no body)';

    debugPrint('[PushNotifications][$context] messageId=${message.messageId ?? '(no id)'}');
    debugPrint('[PushNotifications][$context] title=$title');
    debugPrint('[PushNotifications][$context] body=$body');
    if (message.data.isNotEmpty) {
      debugPrint('[PushNotifications][$context] data=${message.data}');
    }
  }
}
