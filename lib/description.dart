import 'package:flutter/material.dart';
import 'package:ecommerce_practice/favourites.dart';

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

    // initialize state based on store
    isFavorite = isFavorite = favoritesNotifier.value.contains(_item);

    // listen for external changes so UI stays consistent
    _listener = () {
      final currentlyFav = favoritesNotifier.value.contains(_item);
      if (mounted && currentlyFav != isFavorite) {
        setState(() {
          isFavorite = currentlyFav;
        });
      }
    };
    favoritesNotifier.addListener(_listener!);
  }

  @override
  void dispose() {
    if (_listener != null) favoritesNotifier.removeListener(_listener!);
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
                            color: Colors.green),
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
                      print('"${widget.title}" added to cart!');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added ${widget.title} to cart!'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 50), 
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Add to Cart'),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  iconSize: 30,
                  tooltip: 'Go to Cart',
                  onPressed: () {
                    print('Go to Cart tapped!');
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
                    // update shared store and local UI
                    toggleFavorite(_item);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}