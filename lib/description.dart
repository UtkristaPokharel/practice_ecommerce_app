import 'package:flutter/material.dart';

class DescriptionPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(imageUrl, height: 200),
            const SizedBox(height: 16),
            Text(
              'Rs $price',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description.isEmpty ? 'No description available.' : description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
