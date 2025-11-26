import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class BottomNavbar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const BottomNavbar({super.key, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const Icon(Icons.home, size: 30) ,
      const Icon(Icons.category, size: 30),
      const Icon(Icons.favorite, size: 30),
      const Icon(Icons.shopping_cart, size: 30),
      const Icon(Icons.person, size: 30),
    ];

    return CurvedNavigationBar(
      index: index,
      backgroundColor: Colors.transparent,
      color: Theme.of(context).colorScheme.primaryContainer,
      buttonBackgroundColor: Theme.of(context).colorScheme.primary,
      animationDuration: const Duration(milliseconds: 400),
      items: items,
      onTap: onTap,
    );
  }
}
