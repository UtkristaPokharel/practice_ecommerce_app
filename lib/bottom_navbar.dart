import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const Icon(Icons.home, size: 30),
      const Icon(Icons.category, size: 30),
      const Icon(Icons.favorite, size: 30),
      const Icon(Icons.shopping_cart, size: 30),
      const Icon(Icons.person, size: 30),
    ];

    return CurvedNavigationBar(
      index: _index,
      backgroundColor: Colors.transparent,
      color: Theme.of(context).colorScheme.primaryContainer,
      buttonBackgroundColor: Theme.of(context).colorScheme.primary,
      animationDuration: const Duration(milliseconds: 300),
      items: items,
      onTap: (selectedIndex) {
        setState(() {
          _index = selectedIndex;
        });
      },
    );
  }
}
