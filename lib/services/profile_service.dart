import 'dart:convert';
import 'api_helper.dart';
import 'auth_service.dart';
import '../controller/profile_controller.dart';

class ProfileService {
  /// Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
  }) async {
    try {
      final body = {
        "first_name": firstName,
        "last_name": lastName,
        "username": username,
        "email": email,
      };

      final response = await ApiHelper.post('/customer/profile/edit', body);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Update local user data immediately
        if (responseData['data'] != null) {
          await AuthService.saveUserData(responseData['data']);
          await ProfileController.setUserData(responseData['data']);
        }
        
        return {
          'success': true,
          'message': responseData['message'] ?? 'Profile updated successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update profile',
          'errors': responseData['errors'],
        };
      }
    } catch (e) {
      print('Error updating profile: $e');
      return {
        'success': false,
        'message': 'An error occurred while updating profile: $e',
      };
    }
  }

  /// Get user profile
  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await ApiHelper.get('/customer/profile');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
    return null;
  }
}
