import 'package:flutter/material.dart';
import 'package:ecommerce_practice/pages/description.dart';

class CartItem {
  final String title;
  final String imageUrl;
  final String price;
  final String description;

  CartItem({
    required this.title,
    required this.imageUrl,
    required this.price,
    this.description = '',
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.title == title &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode => Object.hash(title, imageUrl);
}

final ValueNotifier<List<CartItem>> cartNotifier =
    ValueNotifier<List<CartItem>>([]);

bool isInCart(CartItem item) {
  return cartNotifier.value.contains(item);
}

void addCartItem(CartItem item) {
  final list = List<CartItem>.from(cartNotifier.value);
  if (!list.contains(item)) {
    list.add(item);
    cartNotifier.value = list;
  }
}

void removeCartItem(CartItem item) {
  final list = List<CartItem>.from(cartNotifier.value);
  if (list.remove(item)) {
    cartNotifier.value = list;
  }
}

void toggleCartItem(CartItem item) {
  if (isInCart(item)) {
    removeCartItem(item);
  } else {
    addCartItem(item);
  }
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<List<CartItem>>(
        valueListenable: cartNotifier,
        builder: (context, list, _) {
          if (list.isEmpty) {
            return const Center(child: Text('No items added to cart yet'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "My Favourites",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 254, 30, 30),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return ListTile(
                        leading: Image.network(
                          item.imageUrl,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                        title: Text(item.title),
                        subtitle: Text('Rs ${item.price}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () => removeCartItem(item),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DescriptionPage(
                                title: item.title,
                                imageUrl: item.imageUrl,
                                price: item.price,
                                description: item.description,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
