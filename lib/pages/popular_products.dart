import 'package:flutter/material.dart';
import '../components/grid.dart';
// import '../searchbar.dart';

class PopularProductsPage extends StatefulWidget {
  const PopularProductsPage({super.key});

  @override
  State<PopularProductsPage> createState() => _PopularProductsPageState();
}

class _PopularProductsPageState extends State<PopularProductsPage> {
  String searchQuery = '';

  // void _handleSearchChanged(String newQuery) {
  //   setState(() {
  //     searchQuery = newQuery;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Popular Products'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // MySearchBar(onSearchChanged: _handleSearchChanged),
            const SizedBox(height: 16.0),
            Mygrid(
              searchQuery: searchQuery,
              onCategoriesFetched: (_) {},
              apiEndpoint:
                  'https://ecommerce.atithyahms.com/api/ecommerce/products/popular',
            ),
          ],
        ),
      ),
    );
  }
}
