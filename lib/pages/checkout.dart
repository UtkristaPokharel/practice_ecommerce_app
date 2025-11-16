import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';
import '../services/order_service.dart';
import 'cart.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> selectedItems;
  final double totalAmount;

  const CheckoutPage({
    super.key,
    required this.selectedItems,
    required this.totalAmount,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  List<dynamic> addresses = [];
  bool isLoading = true;
  String? errorMessage;
  int? selectedAddressId;
  bool isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final token = await AuthService.getToken();

      if (token == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'Please login first';
        });
        return;
      }

      final response = await http.get(
        Uri.parse(
          'https://ecommerce.atithyahms.com/api/ecommerce/customer/address',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          // Handle different possible response structures
          if (data['data'] != null) {
            addresses = data['data'] is List ? data['data'] : [data['data']];
          } else if (data['addresses'] != null) {
            addresses = data['addresses'] is List
                ? data['addresses']
                : [data['addresses']];
          } else if (data is List) {
            addresses = data;
          } else {
            addresses = [];
          }
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load addresses: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _placeOrder() async {
    if (selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a delivery address'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isPlacingOrder = true;
    });

    try {
      // Convert cart items to order items format
      // Note: Using 1 as default product ID since we don't have real product IDs yet
      final orderItems = widget.selectedItems.map((item) {
        return {
          'id': 1, // Using 1 as default - should be real product ID
          'productname': item.title,
          'price': item.price.toInt(),
          'qty': item.quantity,
          'imgUrl': item.imageUrl,
          'storeId': 1, // Default store ID
          'variant': false,
          'vId': null,
          'vProductname': null,
        };
      }).toList();

      print('🛒 Selected Address ID: $selectedAddressId');
      print('🛒 Order Items: $orderItems');

      final result = await OrderService.placeOrder(
        deliveryAddressId: selectedAddressId!,
        discount: '0.0',
        grossAmount: widget.totalAmount,
        netAmount: widget.totalAmount,
        remark: '',
        couponCode: '',
        orderItems: orderItems,
      );

      setState(() {
        isPlacingOrder = false;
      });

      if (result['success'] == true) {
        // Note: Orders will be fetched from the API in My Orders page
        // No need to manually add orders here anymore

        // Remove selected items from cart
        final currentCart = List<CartItem>.from(cartNotifier.value);
        for (var item in widget.selectedItems) {
          currentCart.remove(item);
        }
        cartNotifier.value = currentCart;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Order placed successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to cart or home
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to place order'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        isPlacingOrder = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error placing order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout'), elevation: 0),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchAddresses,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Order Summary Section
                Container(
                  padding: const EdgeInsets.all(16),
                  color: isDark ? Colors.grey[900] : Colors.grey[100],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Items: ${widget.selectedItems.length}'),
                          Text(
                            'Total: Rs ${widget.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Address Selection Section
                Expanded(
                  child: addresses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_off,
                                size: 64,
                                color: isDark
                                    ? Colors.grey[600]
                                    : Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No addresses saved yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await Navigator.pushNamed(
                                    context,
                                    '/shipping-address',
                                  );
                                  _fetchAddresses();
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add Address'),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Select Delivery Address',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () async {
                                      await Navigator.pushNamed(
                                        context,
                                        '/shipping-address',
                                      );
                                      _fetchAddresses();
                                    },
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text('Add New'),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: addresses.length,
                                itemBuilder: (context, index) {
                                  final address = addresses[index];
                                  final addressId = address['id'];
                                  final isSelected =
                                      selectedAddressId == addressId;

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    elevation: isSelected ? 4 : 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: isSelected
                                            ? theme.primaryColor
                                            : (isDark
                                                  ? Colors.grey[700]!
                                                  : Colors.grey[300]!),
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedAddressId = addressId;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            Radio<int>(
                                              value: addressId,
                                              groupValue: selectedAddressId,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedAddressId = value;
                                                });
                                              },
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.location_on,
                                                        size: 18,
                                                        color: Colors.blue,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        address['nickname'] ??
                                                            'Address',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: isDark
                                                              ? Colors.white
                                                              : Colors.black87,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  if (address['complete_address'] !=
                                                      null)
                                                    Text(
                                                      address['complete_address'],
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: isDark
                                                            ? Colors.grey[300]
                                                            : Colors.grey[800],
                                                      ),
                                                    ),
                                                  if (address['delivery_area'] !=
                                                      null) ...[
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      address['delivery_area'],
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: isDark
                                                            ? Colors.grey[400]
                                                            : Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                  if (address['contact_no'] !=
                                                      null) ...[
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.phone,
                                                          size: 14,
                                                          color: isDark
                                                              ? Colors.grey[400]
                                                              : Colors
                                                                    .grey[600],
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          address['contact_no'],
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: isDark
                                                                ? Colors
                                                                      .grey[400]
                                                                : Colors
                                                                      .grey[600],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                ),

                // Place Order Button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isPlacingOrder ? null : _placeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isPlacingOrder
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Place Order - Rs ${widget.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
