import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ecommerce_practice/grid.dart';
import 'package:ecommerce_practice/searchbar.dart';
import 'package:ecommerce_practice/controller/profile_controller.dart';

class HomePage extends StatefulWidget {
  final String initialSearchQuery;
  final ValueChanged<String>? onSearchChanged;

  const HomePage({
    super.key,
    this.initialSearchQuery = '',
    this.onSearchChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String searchQuery;

  @override
  void initState() {
    super.initState();
    searchQuery = widget.initialSearchQuery;
  }

  void _handleSearchChanged(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });
    if (widget.onSearchChanged != null) {
      widget.onSearchChanged!(newQuery);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        title: Row(
          children: [
            // Show the shared profile image if the user uploaded one,
            // otherwise fall back to a default network icon (same as Profile page)
            ValueListenableBuilder<File?>(
              valueListenable: profileImageNotifier,
              builder: (context, file, _) {
                return CircleAvatar(
                  radius: 25,
                  backgroundImage: file != null
                      ? FileImage(file)
                      : const NetworkImage(
                          'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                        ) as ImageProvider,
                );
              },
            ),
            const SizedBox(width: 12),
            // Show dynamic name and greeting using shared name notifier
            ValueListenableBuilder<String>(
              valueListenable: profileNameNotifier,
              builder: (context, name, _) {
                String greeting;
                final hour = DateTime.now().hour;
                if (hour < 12) {
                  greeting = 'Good morning';
                } else if (hour < 17) {
                  greeting = 'Good afternoon';
                } else {
                  greeting = 'Good evening';
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hello ${name.isNotEmpty ? name.split(' ').first : 'User'}',
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    Text(
                      greeting + '!',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  color: Colors.black,
                  size: 28,
                ),
                onPressed: () {
                },
              ),
              Positioned(
                right: 11,
                top: 11,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8), // spacing on the right
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            MySearchBar(onSearchChanged: _handleSearchChanged),
            const SizedBox(height: 16.0),
            Mygrid(searchQuery: searchQuery, onCategoriesFetched: (_) {}),
          ],
        ),
      ),
    );
  }
}
