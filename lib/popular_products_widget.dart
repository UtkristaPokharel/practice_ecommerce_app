import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ecommerce_practice/pages/description.dart';
import 'package:ecommerce_practice/pages/cart.dart';

class PopularProductsWidget extends StatefulWidget {
  final int maxProducts;

  const PopularProductsWidget({
    super.key,
    this.maxProducts = 4,
  });

  @override
  State<PopularProductsWidget> createState() => _PopularProductsWidgetState();
}

class _PopularProductsWidgetState extends State<PopularProductsWidget> {
  late Future<List<Map<String, String>>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts = fetchProducts();
  }

  Future<List<Map<String, String>>> fetchProducts() async {
    final response = await http.get(
      Uri.parse(
          'https://ecommerce.atithyahms.com/api/ecommerce/products/popular'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
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
    return FutureBuilder<List<Map<String, String>>>(
      future: _futureProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No popular products found'));
        }

        final products = snapshot.data!.take(widget.maxProducts).toList();

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(0),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (BuildContext context, int index) {
            final item = products[index];
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
                elevation: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withAlpha(30),
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
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          ValueListenableBuilder<List<CartItem>>(
                            valueListenable: cartNotifier,
                            builder: (context, cartList, _) {
                              final cartItem = CartItem(
                                title: title,
                                imageUrl: imageUrl,
                                price: _parsePrice(price),
                                description: description,
                              );
                              final inCart = isInCart(cartItem);
                              
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Rs $price',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      fontSize: 14,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      if (inCart) {
                                        removeCartItem(cartItem);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('$title removed from cart'),
                                            duration: const Duration(seconds: 1),
                                          ),
                                        );
                                      } else {
                                        addCartItem(cartItem);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('$title added to cart'),
                                            duration: const Duration(seconds: 1),
                                          ),
                                        );
                                      }
                                    },
                                    icon: Icon(
                                      inCart ? Icons.remove_shopping_cart : Icons.add_shopping_cart,
                                      size: 20,
                                    ),
                                    color: inCart ? Colors.red : Theme.of(context).colorScheme.primary,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
