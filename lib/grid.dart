import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ecommerce_practice/pages/description.dart';

class Mygrid extends StatefulWidget {
  final String searchQuery;
  final double minPrice;
  final double maxPrice;
  final String category;
  final ValueChanged<List<String>> onCategoriesFetched;
  final String description;

  const Mygrid({
    super.key,
    this.searchQuery = '',
    this.minPrice = 0.0,
    this.maxPrice = double.infinity,
    this.category = 'All',
    required this.onCategoriesFetched,
    this.description = '',
  });

  @override
  State<Mygrid> createState() => _MygridState();
}

class _MygridState extends State<Mygrid> {
  late Future<List<Map<String, String>>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts = fetchProducts();
  }

  Future<List<Map<String, String>>> fetchProducts() async {
    final response = await http.get(
      Uri.parse('https://ecommerce.atithyahms.com/api/ecommerce/products/all'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;

      final categotySet = <String>{};
      for (var item in data) {
        final category = item['category_name'];
        if (category != null) {
          categotySet.add(category);
        }
      }
      widget.onCategoriesFetched(['All', ...categotySet.toList()]);
      return data.map<Map<String, String>>((item) {
        return {
          'title': item['product_name'],
          'image': item['image'],
          'price': item['price']?.toString() ?? '0',
          'category': item['category_name'] ?? 'Other',
          'description': item['description'] ?? '',
        };
      }).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  double _parsePrice(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final query = widget.searchQuery.trim().toLowerCase();

    return FutureBuilder<List<Map<String, String>>>(
      future: _futureProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No products found'));
        }

        final filtered = snapshot.data!.where((item) {
          final title = item['title']!.toLowerCase();
          final matchesName = query.isEmpty ? true : title.contains(query);

          final priceValue = _parsePrice(item['price']!);
          final matchesPrice =
              priceValue >= widget.minPrice && priceValue <= widget.maxPrice;

          final matchesCategory = widget.category == 'All'
              ? true
              : item['category'] == widget.category;

          return matchesName && matchesPrice && matchesCategory;
        }).toList();

        if (filtered.isEmpty) {
          return const Center(child: Text('No results found'));
        }

        return Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: filtered.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 5.0,
              mainAxisSpacing: 5.0,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (BuildContext context, int index) {
              final item = filtered[index];
              final title = item['title']!;
              final imageUrl = item['image']!;
              final price = item['price']!;
              final description = item['description']!;

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DescriptionPage(
                        title: title,
                        imageUrl: imageUrl,
                        price: price,
                        description: description,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(15.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(30),
                              child: Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rs $price',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
