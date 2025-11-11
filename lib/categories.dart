import 'package:flutter/material.dart';
import 'grid.dart';
import 'searchbar.dart';

class MyCategorie extends StatefulWidget {
  final String searchQuery;
  const MyCategorie({super.key, this.searchQuery = ''});

  @override
  State<MyCategorie> createState() => _MyCategorieState();
}

class _MyCategorieState extends State<MyCategorie> {
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    // preserve any initial searchQuery passed to the widget
    searchQuery = widget.searchQuery;
  }

  void _handleSearchChanged(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        MySearchBar(
          onSearchChanged: _handleSearchChanged,
        ),
        Expanded(
          // pass the state's searchQuery so the grid reacts to the search input
          child: Mygrid(searchQuery: searchQuery),
        ),
      ],
    );
  }
}
