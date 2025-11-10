import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Mygrid extends StatefulWidget {
  final String searchQuery;
  const Mygrid({super.key, this.searchQuery = ''});

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
      return data.map<Map<String, String>>((item) {
        return {
          'title': item['product_name'],
          'image': item['image'],
          'price': item['price'],
        };
      }).toList();
    } else {
      throw Exception('Failed to load products');
    }
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

        final filtered = query.isEmpty
            ? snapshot.data!
            : snapshot.data!
                  .where((item) => item['title']!.toLowerCase().contains(query))
                  .toList();

        if (filtered.isEmpty) {
          return const Center(child: Text('No results found'));
        }

        return Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: filtered.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (BuildContext context, int index) {
              final item = filtered[index];
              final title = item['title']!;
              final imageUrl = item['image']!;
              final price = item['price']!;

              return Card(
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
              );
            },
          ),
        );
      },
    );
  }
}
