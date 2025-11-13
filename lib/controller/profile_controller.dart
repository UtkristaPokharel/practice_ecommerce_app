import 'dart:io';
import 'package:flutter/foundation.dart';

// Notifier for profile image so multiple pages can react to changes
final ValueNotifier<File?> profileImageNotifier = ValueNotifier<File?>(null);

// Notifier for profile name so Home can display the updated name
final ValueNotifier<String> profileNameNotifier = ValueNotifier<String>('John Doe');

class ProfileController {
  // Store the logged-in user data globally
  static Map<String, dynamic>? userData;

  // Set user data after login or edit
  static void setUserData(Map<String, dynamic> data) {
    userData = data;

    // Update profile name notifier automatically
    final firstName = data['first_name'] ?? '';
    final lastName = data['last_name'] ?? '';
    profileNameNotifier.value = '$firstName $lastName';
  }

  // Clear user data on logout
  static void clearUserData() {
    userData = null;
    profileNameNotifier.value = 'John Doe';
    profileImageNotifier.value = null;
  }

  // Getters for easy access
  static String get firstName => userData?['first_name'] ?? '';
  static String get lastName => userData?['last_name'] ?? '';
  static String get fullName => '${firstName} ${lastName}';
  static String get phone => userData?['mobile_no'] ?? '';
}
