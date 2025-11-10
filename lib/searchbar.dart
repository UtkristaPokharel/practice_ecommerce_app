import 'package:flutter/material.dart';

class MySearchBar extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onThemeToggle;
  final ValueChanged<String> onSearchChanged;

  const MySearchBar({
    super.key,
    required this.isDark,
    required this.onThemeToggle,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Theme toggle button
        IconButton(
          icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
          onPressed: () {
            onThemeToggle(!isDark);
          },
        ),
        // Search input
        Expanded(
          child: TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            ),
          ),
        ),
      ],
    );
  }
}
