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

  double _priceRangeStart =0.0;
  double _priceRangeEnd =1000.0;
  final double _minPrice =0.0;
  final double _maxPrice =1000.0;

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

  void _handlePriceRangeChanged(RangeValues values) {
    setState(() {
      _priceRangeStart = values.start;
      _priceRangeEnd = values.end;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          MySearchBar(
            onSearchChanged: _handleSearchChanged,
          ),
           const SizedBox(height: 16.0),
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
           Mygrid(
            searchQuery: searchQuery,
            minPrice: _priceRangeStart,
            maxPrice: _priceRangeEnd,),
        ],
      ),
    );
  }
}
