import 'package:flutter/material.dart';
import 'package:ecommerce_practice/grid.dart';
import 'package:ecommerce_practice/searchbar.dart';
import 'package:ecommerce_practice/bottom_navbar.dart';
import 'package:ecommerce_practice/profilepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDark = false;
  String searchQuery = '';
  int _selectedIndex = 0;

  void _handleThemeToggle(bool newIsDark) {
    setState(() {
      isDark = newIsDark;
    });
  }

  void _handleSearchChanged(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });
  }

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    final ThemeData themeData = ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      useMaterial3: true,
      colorScheme: isDark
          ? const ColorScheme.dark(
              primary: Color.fromARGB(255, 0, 149, 255),
              secondary: Color.fromARGB(255, 25, 0, 255),
              surface: Color.fromARGB(255, 1, 1, 1), 
              onPrimary: Colors.white,
              onSecondary: Colors.white,
            )
          : const ColorScheme.light(
              primary: Colors.blueAccent,
              secondary: Color.fromARGB(255, 0, 30, 255),
              surface: Colors.white,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
            ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: Scaffold(
        appBar: AppBar(title: const Text('My E-commerce App')),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            // Home
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  MySearchBar(
                    isDark: isDark,
                    onThemeToggle: _handleThemeToggle,
                    onSearchChanged: _handleSearchChanged,
                  ),
                  const SizedBox(height: 16.0),
                  Mygrid(searchQuery: searchQuery),
                ],
              ),
            ),

            const Center(child: Text('Categories')),
            const Center(child: Text('Favorites')),
            const Center(child: Text('Cart')),
            const MyProfile(),
          ],
        ),
        bottomNavigationBar: BottomNavbar(index: _selectedIndex, onTap: _onNavTapped),
      ),
    );
  }
}
