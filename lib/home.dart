import 'package:flutter/material.dart';
import 'package:ecommerce_practice/grid.dart';
import 'package:ecommerce_practice/searchbar.dart';

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
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            MySearchBar(
              onSearchChanged: _handleSearchChanged,
            ),
            const SizedBox(height: 16.0),
            Mygrid(
              searchQuery: searchQuery,
              onCategoriesFetched: (_) {},
            ),
          ],
        ),
      ),
    );
  }
}
