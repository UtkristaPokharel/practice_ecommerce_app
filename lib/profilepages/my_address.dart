import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';

class MyAddressPage extends StatefulWidget {
  const MyAddressPage({super.key});

  @override
  State<MyAddressPage> createState() => _MyAddressPageState();
}

class _MyAddressPageState extends State<MyAddressPage> {
  List<dynamic> addresses = [];
  bool isLoading = true;
  String? errorMessage;

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
        Uri.parse('https://ecommerce.atithyahms.com/api/ecommerce/customer/address'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Address fetch status: ${response.statusCode}');
      print('Address fetch response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          // Handle different possible response structures
          if (data['data'] != null) {
            addresses = data['data'] is List ? data['data'] : [data['data']];
          } else if (data['addresses'] != null) {
            addresses = data['addresses'] is List ? data['addresses'] : [data['addresses']];
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
      print('Error fetching addresses: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _editAddress(dynamic address) async {
    // Navigate to shipping address page with address data
    await Navigator.pushNamed(
      context,
      '/shipping-address',
      arguments: address, // Pass the address data for editing
    );
    _fetchAddresses(); // Refresh the list after editing
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Addresses'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // Navigate to add address page
              await Navigator.pushNamed(context, '/shipping-address');
              _fetchAddresses(); // Refresh when coming back
            },
            tooltip: 'Add Address',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchAddresses,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : addresses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off,
                            size: 64,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No addresses saved yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.pushNamed(context, '/shipping-address');
                              _fetchAddresses();
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Address'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchAddresses,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: addresses.length,
                        itemBuilder: (context, index) {
                          final address = addresses[index];
                          return _buildAddressCard(address, isDark);
                        },
                      ),
                    ),
    );
  }

  Widget _buildAddressCard(dynamic address, bool isDark) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with nickname and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: theme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            address['nickname'] ?? 'Address',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _editAddress(address),
                    tooltip: 'Edit',
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              // Address details
              if (address['delivery_area'] != null) ...[
                _buildAddressRow(
                  Icons.location_city,
                  'Area',
                  address['delivery_area'],
                  isDark,
                ),
                const SizedBox(height: 8),
              ],

              if (address['complete_address'] != null) ...[
                _buildAddressRow(
                  Icons.home,
                  'Address',
                  address['complete_address'],
                  isDark,
                ),
                const SizedBox(height: 8),
              ],

              if (address['contact_no'] != null) ...[
                _buildAddressRow(
                  Icons.phone,
                  'Contact',
                  address['contact_no'],
                  isDark,
                ),
                const SizedBox(height: 8),
              ],

              if (address['delivery_instructions'] != null &&
                  address['delivery_instructions'].toString().isNotEmpty) ...[
                _buildAddressRow(
                  Icons.info_outline,
                  'Instructions',
                  address['delivery_instructions'],
                  isDark,
                ),
                const SizedBox(height: 8),
              ],

              if (address['latitude'] != null && address['longitude'] != null) ...[
                _buildAddressRow(
                  Icons.map,
                  'Coordinates',
                  '${address['latitude']}, ${address['longitude']}',
                  isDark,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[200] : Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
