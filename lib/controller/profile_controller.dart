import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

// Notifier for profile image so multiple pages can react to changes
final ValueNotifier<File?> profileImageNotifier = ValueNotifier<File?>(null);

// Notifier for remote image URLs (e.g., Google profile photos)
final ValueNotifier<String?> profileImageUrlNotifier = ValueNotifier<String?>(null);

// Notifier for profile name so Home can display the updated name
final ValueNotifier<String> profileNameNotifier = ValueNotifier<String>(
  'John Doe',
);

class ProfileController {
  // Store the logged-in user data globally
  static Map<String, dynamic>? userData;
  static String? authToken;

  // Set user data after login or edit
  static Future<void> setUserData(
    Map<String, dynamic> data, {
    String? token,
  }) async {
    userData = data;
    _updateProfileImageUrl(data);

    if (token != null) {
      authToken = token;
      await AuthService.saveToken(token);
    }

    await AuthService.saveUserData(data);
    _updateProfileName(data);
  }

  static Future<void> loadUserData() async {
    userData = await AuthService.getUserData();
    authToken = await AuthService.getToken();

    if (userData != null) {
      _updateProfileName(userData!);
      _updateProfileImageUrl(userData!);
    }
  }

  // Clear user data on logout
  static Future<void> clearUserData() async {
    userData = null;
    authToken = null;
    profileNameNotifier.value = 'John Doe';
    profileImageNotifier.value = null;
    profileImageUrlNotifier.value = null;

    await AuthService.clearAuth();
  }

  static String get firstName => userData?['first_name'] ?? '';
  static String get lastName => userData?['last_name'] ?? '';
  static String get fullName => '$firstName $lastName';
  static String get phone =>
      userData?['mobile_no'] ??
      userData?['phone'] ??
      userData?['mobile'] ??
      userData?['phone_number'] ??
      '';
  static String get profileImageUrl => profileImageUrlNotifier.value ?? '';
  static String? get token => authToken;
  static int? get userId => userData?['id'];
  static int get rewardPoints =>
      userData?['reward_points'] ??
      userData?['rewards'] ??
      userData?['points'] ??
      0;

  static void _updateProfileName(Map<String, dynamic> data) {
    final firstName = data['first_name'] ?? '';
    final lastName = data['last_name'] ?? '';
    profileNameNotifier.value = '$firstName $lastName'.trim();
  }

  static void _updateProfileImageUrl(Map<String, dynamic> data) {
    final url = _extractProfileImageUrl(data);
    profileImageUrlNotifier.value = url.isNotEmpty ? url : null;
  }

  static String _extractProfileImageUrl(Map<String, dynamic> data) {
    final possibleKeys = [
      'profile_image',
      'profileImage',
      'profile_photo',
      'profilePhoto',
      'avatar',
      'image',
      'image_url',
      'photo_url',
    ];

    for (final key in possibleKeys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
    }
    return '';
  }
}
