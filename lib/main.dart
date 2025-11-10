import 'package:flutter/material.dart';
import 'package:ecommerce_practice/grid.dart';
import 'package:ecommerce_practice/searchbar.dart';
import 'package:ecommerce_practice/bottom_navbar.dart';

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

  @override
  Widget build(BuildContext context) {

    final ThemeData themeData = ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      useMaterial3: true,
      colorScheme: isDark
          ? const ColorScheme.dark(
              primary: Color.fromARGB(255, 0, 149, 255),
              secondary: Color.fromARGB(255, 25, 0, 255),
              surface: Color.fromARGB(255, 85, 85, 85), 
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
        body: Padding(
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
        bottomNavigationBar: const BottomNavbar(),
      ),
    );
  }
}
