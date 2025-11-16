import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class ApiHelper {
  static const String baseUrl =
      'https://ecommerce.atithyahms.com/api/ecommerce';

  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Make an authenticated GET request
  static Future<http.Response> get(String endpoint) async {
    final headers = await getAuthHeaders();
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(url, headers: headers);
  }

  /// Make an authenticated POST request
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final headers = await getAuthHeaders();
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(url, headers: headers, body: jsonEncode(body));
  }

  /// Make an authenticated PUT request
  static Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final headers = await getAuthHeaders();
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.put(url, headers: headers, body: jsonEncode(body));
  }

  static Future<http.Response> delete(String endpoint) async {
    final headers = await getAuthHeaders();
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.delete(url, headers: headers);
  }

  static Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final response = await get('/customer/profile');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
    return null;
  }

  /// Example: Fetch user orders
  static Future<List<dynamic>?> fetchUserOrders() async {
    try {
      final response = await get('/customer/orders');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      }
    } catch (e) {
      print('Error fetching orders: $e');
    }
    return null;
  }

  /// Example: Update user profile
  static Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await put('/customer/profile', profileData);
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating profile: $e');
    }
    return false;
  }
}
