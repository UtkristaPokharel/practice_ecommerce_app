import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
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
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'high_priority_channel',
    'High Priority Notifications',
    description: 'Foreground alerts for important updates.',
    importance: Importance.high,
  );
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    if (kIsWeb) {
      debugPrint('[PushNotifications] Skipping initialization on web builds.');
      return;
    }

    await _ensurePermissions();
    await _configureLocalNotifications();
    await _syncInitialToken();
    await _logInitialMessage();

    FirebaseMessaging.onMessage.listen((message) async {
      await _handleForegroundMessage(message);
    });
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

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    _logMessageDetails('foreground', message);
    await _showLocalNotification(message);
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

  static Future<void> _configureLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleLocalNotificationResponse,
    );

    final androidPlugin = _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_androidChannel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title =
        notification?.title ?? message.data['title'] ?? 'New notification';
    final body = notification?.body ?? message.data['body'] ?? '';

    final dynamic rawImage = message.data['image'];
    final imageUrl = notification?.android?.imageUrl ??
        notification?.apple?.imageUrl ??
        (rawImage is String ? rawImage : null);

    await showLocalNotification(
      title: title,
      body: body,
      data: message.data.isEmpty ? null : message.data,
      imageUrl: imageUrl,
    );
  }

  static Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    if (title.trim().isEmpty && body.trim().isEmpty) return;

    final payload = data == null || data.isEmpty ? null : jsonEncode(data);
    final androidDetails =
        await _buildAndroidNotificationDetails(imageUrl: imageUrl);

    const darwinDetails = DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _localNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static Future<AndroidNotificationDetails> _buildAndroidNotificationDetails({
    String? imageUrl,
  }) async {
    BigPictureStyleInformation? styleInfo;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      final bitmap = await _downloadBitmap(imageUrl);
      if (bitmap != null) {
        styleInfo = BigPictureStyleInformation(
          bitmap,
          largeIcon: bitmap,
        );
      }
    }

    return AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      styleInformation: styleInfo,
    );
  }

  static Future<ByteArrayAndroidBitmap?> _downloadBitmap(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        final base64Image = base64Encode(response.bodyBytes);
        return ByteArrayAndroidBitmap.fromBase64String(base64Image);
      }
    } catch (e) {
      debugPrint('[PushNotifications] Failed to download image: $e');
    }
    return null;
  }

  static void _handleLocalNotificationResponse(
    NotificationResponse response,
  ) {
    if (response.payload == null) return;
    debugPrint('[PushNotifications][local-response] payload=${response.payload}');
  }
}
