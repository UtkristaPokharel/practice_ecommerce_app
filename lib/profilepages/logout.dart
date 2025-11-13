import 'package:flutter/material.dart';
import 'package:ecommerce_practice/controller/profile_controller.dart';

class LogoutDialog {
  static void show(
    BuildContext context, {
    required VoidCallback onLogoutConfirmed,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();

                // Execute the logout callback
                onLogoutConfirmed();

                // Navigate to login and remove all previous routes
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (Route<dynamic> route) => false,
                );

                // Show a success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Resets user profile data to default values
  static void clearUserData() {
    profileImageNotifier.value = null;
    profileNameNotifier.value = "John Doe";
  }
}
