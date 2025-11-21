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
      debugPrint('[PushNotifications] App opened via notification: ${message.messageId}');
    }
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[PushNotifications] Foreground notification: ${message.messageId}');
  }

  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('[PushNotifications] Background notification: ${message.messageId}');
  }

  static void _handleNotificationInteraction(RemoteMessage message) {
    debugPrint('[PushNotifications] Notification tapped: ${message.messageId}');
  }
}
