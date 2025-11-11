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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.all(10), 
            child: Text(
              title,
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
            Image.network(imageUrl, width: 400, height: 300),
            const SizedBox(height: 20),
            Text(
              'Rs $price',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold , color: Colors.green),
            ),
            const SizedBox(height: 8),
            Text(
              description.isEmpty ? 'No description available.' : description,
              style: const TextStyle(fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }
}
