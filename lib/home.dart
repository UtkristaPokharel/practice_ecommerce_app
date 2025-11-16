import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ecommerce_practice/searchbar.dart';
import 'package:ecommerce_practice/controller/profile_controller.dart';
import 'package:ecommerce_practice/popular_products_widget.dart';
import 'package:ecommerce_practice/pages/popular_products.dart';
import 'package:ecommerce_practice/banner_carousel.dart';

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
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        title: Row(
          children: [
            ValueListenableBuilder<File?>(
              valueListenable: profileImageNotifier,
              builder: (context, file, _) {
                return CircleAvatar(
                  radius: 25,
                  backgroundImage: file != null
                      ? FileImage(file)
                      : const NetworkImage(
                              'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                            )
                            as ImageProvider,
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
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
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
                onPressed: () {},
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MySearchBar(onSearchChanged: _handleSearchChanged),
              const SizedBox(height: 16.0),
              // Banner Carousel
              const BannerCarousel(),
              const SizedBox(height: 24.0),
              // Popular Products Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Popular Products',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PopularProductsPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              // Show only 4 popular products
              const PopularProductsWidget(maxProducts: 4),
            ],
          ),
        ),
      ),
    );
  }
}
