import 'dart:io';
import 'package:flutter/foundation.dart';

// notifier for profile image so multiple pages can react to changes
final ValueNotifier<File?> profileImageNotifier = ValueNotifier<File?>(null);

// notifier for profile name so Home can display the updated name
final ValueNotifier<String> profileNameNotifier = ValueNotifier<String>(
  'John Doe',
);
