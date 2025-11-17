import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../controller/theme_controller.dart';
import '../controller/profile_controller.dart';
import '../profilepages/logout.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final ImagePicker _picker = ImagePicker();

  String get _fullName => ProfileController.fullName;
  String get _phoneNumber => ProfileController.phone;

  @override
  void initState() {
    super.initState();
    // Ensure the profile name is updated when this page loads
    if (_fullName.isNotEmpty) {
      profileNameNotifier.value = _fullName;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      profileImageNotifier.value = File(pickedFile.path);
      setState(() {});
    }
    Navigator.pop(context);
  }

  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text("Take a Photo"),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    LogoutDialog.show(
      context,
      onLogoutConfirmed: () {
        ProfileController.clearUserData();
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ValueListenableBuilder<File?>(
                    valueListenable: profileImageNotifier,
                    builder: (context, file, _) {
                      return CircleAvatar(
                        radius: 60,
                        backgroundImage: file != null
                            ? FileImage(file)
                            : const NetworkImage(
                                    "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
                                  ) as ImageProvider,
                      );
                    },
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: InkWell(
                      onTap: _showImageSourceSelection,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Reward Points
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.stars,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${ProfileController.rewardPoints} Points',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<String>(
                valueListenable: profileNameNotifier,
                builder: (context, name, _) {
                  return Text(
                    name.isNotEmpty ? name : _fullName,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              Text(
                _phoneNumber,
                style: textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),
              Divider(color: Colors.grey.shade400),

              _buildSectionTitle("Account Settings", theme),
              const SizedBox(height: 8),
              _buildListTile(
                icon: Icons.edit,
                title: "Edit Profile",
                onTap: () async {
                  final result = await Navigator.pushNamed(context, '/edit-profile');
                  if (result != null && result is Map<String, dynamic>) {
                    ProfileController.setUserData(result);
                    setState(() {}); 
                  }
                },
              ),
              _buildListTile(
                icon: Icons.location_on,
                title: "Add Shipping Address",
                onTap: () {
                  Navigator.pushNamed(context, '/shipping-address');
                },
              ),
              _buildListTile(
                icon: Icons.home,
                title: "My Addresses",
                onTap: () {
                  Navigator.pushNamed(context, '/my-address');
                },
              ),
              _buildListTile(
                icon: Icons.shopping_bag,
                title: "My Orders",
                onTap: () {
                  Navigator.pushNamed(context, '/my-orders');
                },
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<bool>(
                valueListenable: isDarkNotifier,
                builder: (context, isDark, _) {
                  return Card(
                    elevation: 1,
                    color: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      value: isDark,
                      onChanged: (val) => isDarkNotifier.value = val,
                      title: Text(
                        'Dark Mode',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withOpacity(0.9)
                              : Colors.black.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      secondary: Icon(
                        isDark ? Icons.dark_mode : Icons.light_mode,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Divider(color: Colors.grey.shade400),
              const SizedBox(height: 8),
              _buildListTile(
                icon: Icons.lock_reset,
                title: "Reset Password",
                onTap: () {
                  Navigator.pushNamed(context, '/password-reset');
                },
              ),
              _buildListTile(
                icon: Icons.logout,
                title: "Logout",
                iconColor: Colors.red,
                textColor: Colors.red,
                onTap: _showLogoutDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 1,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? theme.colorScheme.primary),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ??
                (isDark ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.9)),
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDark ? Colors.grey[300] : Colors.grey[600],
        ),
        onTap: onTap,
      ),
    );
  }
}
