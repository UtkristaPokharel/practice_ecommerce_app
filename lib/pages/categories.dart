import 'package:flutter/material.dart';
import '../components/grid.dart';
import '../searchbar.dart';

class MyCategorie extends StatefulWidget {
  final String searchQuery;
  const MyCategorie({super.key, this.searchQuery = ''});

  @override
  State<MyCategorie> createState() => _MyCategorieState();
}

class _MyCategorieState extends State<MyCategorie> {
  String searchQuery = '';

  double _priceRangeStart = 0.0;
  double _priceRangeEnd = 1000.0;
  final double _minPrice = 0.0;
  final double _maxPrice = 1000.0;

  List<String> categories = ['All'];
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    searchQuery = widget.searchQuery;
  }

  void _handleSearchChanged(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });
  }

  void _handlePriceRangeChanged(RangeValues values) {
    setState(() {
      _priceRangeStart = values.start;
      _priceRangeEnd = values.end;
    });
  }

  Widget _categorySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = category == selectedCategory;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            // Search bar
            MySearchBar(onSearchChanged: _handleSearchChanged),
            const SizedBox(height: 16.0),

            // Price filter
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter by Price',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                RangeSlider(
                  values: RangeValues(_priceRangeStart, _priceRangeEnd),
                  min: _minPrice,
                  max: _maxPrice,
                  divisions: 20,
                  labels: RangeLabels(
                    'Rs ${_priceRangeStart.toStringAsFixed(0)}',
                    'Rs ${_priceRangeEnd.toStringAsFixed(0)}',
                  ),
                  onChanged: _handlePriceRangeChanged,
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Category selector
            _categorySelector(),
            const SizedBox(height: 16.0),

            // Product grid
            Mygrid(
              searchQuery: searchQuery,
              minPrice: _priceRangeStart,
              maxPrice: _priceRangeEnd,
              category: selectedCategory,
              onCategoriesFetched: (fetchedCategories) {
                setState(() {
                  categories = fetchedCategories;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
