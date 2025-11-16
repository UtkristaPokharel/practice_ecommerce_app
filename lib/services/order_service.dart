import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class OrderService {
  static const String baseUrl =
      'https://ecommerce.atithyahms.com/api/v2/ecommerce/customer/orders';
  static const String trackBaseUrl =
      'https://ecommerce.atithyahms.com/api/ecommerce/customer/orders';

  /// Fetch tracked orders from the API
  static Future<Map<String, dynamic>> fetchTrackedOrders() async {
    try {
      final token = await AuthService.getToken();

      if (token == null) {
        return {'success': false, 'message': 'Please login first', 'data': []};
      }

      final response = await http.get(
        Uri.parse('$trackBaseUrl/track'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📦 Track Orders Response Status: ${response.statusCode}');
      print('📦 Track Orders Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Orders fetched successfully',
          'data': data['data'] ?? [],
        };
      } else {
        String errorMessage = 'Failed to fetch orders: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          print('📦 Error parsing response: $e');
        }

        return {'success': false, 'message': errorMessage, 'data': []};
      }
    } catch (e) {
      print('📦 Exception fetching orders: $e');
      return {'success': false, 'message': 'Error: $e', 'data': []};
    }
  }

  static Future<Map<String, dynamic>> placeOrder({
    required int deliveryAddressId,
    required String discount,
    required double grossAmount,
    required double netAmount,
    String remark = '',
    String couponCode = '',
    required List<Map<String, dynamic>> orderItems,
  }) async {
    try {
      final token = await AuthService.getToken();

      if (token == null) {
        return {'success': false, 'message': 'Please login first'};
      }

      final body = {
        'delivery_address_id': deliveryAddressId,
        'discount': discount,
        'gross_amount': grossAmount,
        'net_amount': netAmount,
        'remark': remark,
        'coupon_code': couponCode,
        'order_item': orderItems,
      };

      print('📦 Placing order with body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse('$baseUrl/place'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('📦 Order API Response Status: ${response.statusCode}');
      print('📦 Order API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Order placed successfully!',
          'data': data,
        };
      } else {
        // Parse error message from response
        String errorMessage = 'Failed to place order: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          print('📦 Error data: $errorData');
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          } else if (errorData['errors'] != null) {
            final errors = errorData['errors'] as Map<String, dynamic>;
            errorMessage = errors.values.first.toString();
          } else if (errorData['error'] != null) {
            errorMessage = errorData['error'];
          }
        } catch (e) {
          print('📦 Error parsing response: $e');
        }

        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
