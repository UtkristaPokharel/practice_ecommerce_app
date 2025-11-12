import 'package:flutter/material.dart';
import 'package:ecommerce_practice/pages/favourites.dart';
import 'package:ecommerce_practice/pages/cart.dart';

class DescriptionPage extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String price;
  final String description;

  const DescriptionPage({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.description = '',
  });

  @override
  State<DescriptionPage> createState() => _DescriptionPageState();
}

class _DescriptionPageState extends State<DescriptionPage> {
  bool isFavorite = false;
  late final FavoriteItem _item;
  late final CartItem _cartItem;
  bool isInCartItem = false;
  VoidCallback? _listener;

  @override
  void initState() {
    super.initState();
    _item = FavoriteItem(
      title: widget.title,
      imageUrl: widget.imageUrl,
      price: widget.price,
      description: widget.description,
    );

    _cartItem = CartItem(
      title: widget.title,
      imageUrl: widget.imageUrl,
      price: widget.price,
      description: widget.description,
    );
    isFavorite = favoritesNotifier.value.contains(_item);
    isInCartItem = cartNotifier.value.contains(_cartItem);

    _listener = () {
      final currentlyFav = favoritesNotifier.value.contains(_item);
      final currentlyInCart = cartNotifier.value.contains(_cartItem);
      if (mounted && (currentlyFav != isFavorite || currentlyInCart != isInCartItem)) {
        setState(() {
          isFavorite = currentlyFav;
          isInCartItem = currentlyInCart;
        });
      }
    };
    favoritesNotifier.addListener(_listener!);
    cartNotifier.addListener(_listener!);
  }

  @override
  void dispose() {
    if (_listener != null) {
      favoritesNotifier.removeListener(_listener!);
      cartNotifier.removeListener(_listener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Image.network(widget.imageUrl, width: 400, height: 300),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Rs ${widget.price}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.description.isEmpty
                          ? 'No description available.'
                          : widget.description,
                      style: const TextStyle(fontSize: 17),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final wasInCart = isInCartItem;
                      // toggle the item in the global cart notifier
                      toggleCartItem(_cartItem);

                      // show a snackbar reflecting the action
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            wasInCart
                                ? 'Removed ${widget.title} from cart!'
                                : 'Added ${widget.title} to cart!',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );

                      if (mounted) {
                        setState(() {
                          isInCartItem = !wasInCart;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 50),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text(
                      isInCartItem ? 'Remove from Cart' : 'Add to Cart',
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  iconSize: 30,
                  tooltip: 'Go to Cart',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    );
                  },
                ),

                const SizedBox(width: 8),

                IconButton(
                  tooltip: 'Favorite',
                  iconSize: 30,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                  color: isFavorite ? Colors.red : null,
                  onPressed: () {
                    toggleFavorite(_item);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
