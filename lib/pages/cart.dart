import 'package:flutter/material.dart';
import 'package:ecommerce_practice/pages/description.dart';

class CartItem {
  final String title;
  final String imageUrl;
  final double price;
  final String description;
  int quantity;
  bool isSelected;

  CartItem({
    required this.title,
    required this.imageUrl,
    required this.price,
    this.description = '',
    this.quantity = 1,
    this.isSelected = true,
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

  double calculateTotal(List<CartItem> items) {
    double total = 0;
    for (var item in items) {
      if (item.isSelected) {
        total += item.price * item.quantity;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<List<CartItem>>(
        valueListenable: cartNotifier,
        builder: (context, list, _) {
          if (list.isEmpty) {
            return const Center(child: Text('No items added to cart yet'));
          }

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "My Cart",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 254, 30, 30),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.scale(
                              scale: 0.8,
                              child: Checkbox(
                                value: item.isSelected,
                                onChanged: (value) {
                                  item.isSelected = value!;
                                  cartNotifier.value = List<CartItem>.from(
                                    cartNotifier.value,
                                  );
                                },
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: item.imageUrl.startsWith('http')
                                  ? Image.network(
                                      item.imageUrl,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.broken_image),
                                    )
                                  : Image.asset(
                                      item.imageUrl,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ],
                        ),
                        title: Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Rs ${item.price}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 0),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints.tightFor(
                                    width: 24,
                                    height: 24,
                                  ),
                                  iconSize: 16,
                                  splashRadius: 16,
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    if (item.quantity > 1) {
                                      item.quantity--;
                                      cartNotifier.value = List<CartItem>.from(
                                        cartNotifier.value,
                                      );
                                    }
                                  },
                                ),
                                SizedBox(
                                  width: 5,
                                  child: Center(
                                    child: Text(
                                      item.quantity.toString(),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints.tightFor(
                                    width: 24,
                                    height: 24,
                                  ),
                                  iconSize: 16,
                                  splashRadius: 16,
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    item.quantity++;
                                    cartNotifier.value = List<CartItem>.from(
                                      cartNotifier.value,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
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
                                price: item.price.toString(),
                                description: item.description,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: Colors.grey.shade200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ValueListenableBuilder<List<CartItem>>(
                      valueListenable: cartNotifier,
                      builder: (context, list, _) {
                        double total = calculateTotal(list);
                        return Text(
                          'Total: Rs $total',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Checkout clicked')),
                        );
                      },
                      child: const Text('Checkout'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
