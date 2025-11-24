import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';
import 'push_notification_service.dart';

class NotificationService {
  static const String _endpoint =
      'https://ecommerce.atithyahms.com/api/v2/ecommerce/notifications';
  static const String _lastNotificationKey =
      'last_order_notification_id';

  static Future<void> fetchAndDisplayLatestOrderNotification() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        debugPrint('[NotificationService] Missing auth token.');
        return;
      }

      final response = await http.get(
        Uri.parse(_endpoint),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        debugPrint('[NotificationService] Request failed: '
            '${response.statusCode} ${response.reasonPhrase}');
        return;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['success'] == false) {
        debugPrint('[NotificationService] API reported failure.');
        return;
      }

      final List<dynamic> dataList = _extractDataList(decoded);
      if (dataList.isEmpty) {
        debugPrint('[NotificationService] No notification data available.');
        return;
      }

      final Map<String, dynamic> latest =
          Map<String, dynamic>.from(dataList.first);
      final prefs = await SharedPreferences.getInstance();
      final int? lastId = prefs.getInt(_lastNotificationKey);
      final int? currentId = (latest['id'] as num?)?.toInt();

      if (currentId != null && lastId == currentId) {
        debugPrint('[NotificationService] Notification $currentId already shown.');
        return;
      }

      final String title =
          (latest['title'] as String?)?.trim().isNotEmpty == true
              ? (latest['title'] as String).trim()
              : 'Order Update';
      final String body =
          (latest['message'] as String?)?.trim() ?? 'Your order update is ready.';
      final String? imageUrl = latest['image'] as String?;

      final Map<String, dynamic> payload = {
        'id': currentId,
        'type': latest['type'],
        'target_id': latest['target_id'],
        'source': 'order_api',
      }..removeWhere((_, value) => value == null);

      await PushNotificationService.showLocalNotification(
        title: title,
        body: body,
        data: payload.isEmpty ? null : payload,
        imageUrl: imageUrl,
      );

      if (currentId != null) {
        await prefs.setInt(_lastNotificationKey, currentId);
      }
    } catch (e) {
      debugPrint('[NotificationService] Error fetching notification: $e');
    }
  }

  static List<dynamic> _extractDataList(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is List) return data;
      if (data != null) return [data];
    }
    if (decoded is List) return decoded;
    return const [];
  }
}
