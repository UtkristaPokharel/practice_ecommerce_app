import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

// Notifier for profile image so multiple pages can react to changes
final ValueNotifier<File?> profileImageNotifier = ValueNotifier<File?>(null);

// Notifier for profile name so Home can display the updated name
final ValueNotifier<String> profileNameNotifier = ValueNotifier<String>('John Doe');

class ProfileController {
  // Store the logged-in user data globally
  static Map<String, dynamic>? userData;
  static String? authToken;

  // Set user data after login or edit
  static Future<void> setUserData(Map<String, dynamic> data, {String? token}) async {
    userData = data;
    
    if (token != null) {
      authToken = token;
      await AuthService.saveToken(token);
    }
    
    await AuthService.saveUserData(data);

    final firstName = data['first_name'] ?? '';
    final lastName = data['last_name'] ?? '';
    profileNameNotifier.value = '$firstName $lastName';
  }

  static Future<void> loadUserData() async {
    userData = await AuthService.getUserData();
    authToken = await AuthService.getToken();
    
    if (userData != null) {
      final firstName = userData!['first_name'] ?? '';
      final lastName = userData!['last_name'] ?? '';
      profileNameNotifier.value = '$firstName $lastName';
    }
  }

  // Clear user data on logout
  static Future<void> clearUserData() async {
    userData = null;
    authToken = null;
    profileNameNotifier.value = 'John Doe';
    profileImageNotifier.value = null;
    
    // Clear from persistent storage
    await AuthService.clearAuth();
  }

  // Getters for easy access
  static String get firstName => userData?['first_name'] ?? '';
  static String get lastName => userData?['last_name'] ?? '';
  static String get fullName => '${firstName} ${lastName}';
  static String get phone => userData?['mobile_no'] ?? userData?['phone'] ?? userData?['mobile'] ?? userData?['phone_number'] ?? '';
  static String? get token => authToken;
  static int? get userId => userData?['id'];
}
