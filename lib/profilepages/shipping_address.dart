import 'package:flutter/material.dart';

class ShippingAddressPage extends StatelessWidget {
  const ShippingAddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shipping Address')),
      body: const Center(child: Text('Shipping Address Page')),
    );
  }
}