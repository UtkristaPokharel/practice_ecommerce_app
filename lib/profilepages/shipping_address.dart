import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';
import '../controller/profile_controller.dart';

class ShippingAddressPage extends StatefulWidget {
  const ShippingAddressPage({super.key});

  @override
  State<ShippingAddressPage> createState() => _ShippingAddressPageState();
}

class _ShippingAddressPageState extends State<ShippingAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _deliveryAreaController = TextEditingController();
  final TextEditingController _completeAddressController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();
  final TextEditingController _deliveryInstructionsController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _deliveryAreaController.dispose();
    _completeAddressController.dispose();
    _contactNoController.dispose();
    _deliveryInstructionsController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _submitAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get authentication token
      final token = await AuthService.getToken();
      final userId = ProfileController.userId;

      if (token == null || userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please login first'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Prepare request body with minimal required fields
      final body = {
        'nickname': _nicknameController.text,
        'delivery_area': _deliveryAreaController.text,
        'complete_address': _completeAddressController.text,
        'contact_no': _contactNoController.text,
        'delivery_instructions': _deliveryInstructionsController.text,
      };

      // Add optional fields if provided
      if (_latitudeController.text.isNotEmpty) {
        body['latitude'] = _latitudeController.text;
      }
      if (_longitudeController.text.isNotEmpty) {
        body['longitude'] = _longitudeController.text;
      }

      print('Sending address data: $body'); // Debug print

      // Use the correct endpoint for saving address
      final response = await http.post(
        Uri.parse('https://ecommerce.atithyahms.com/api/ecommerce/customer/address/save'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('Response status: ${response.statusCode}'); // Debug print
      print('Response body: ${response.body}'); // Debug print

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Address saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Clear form
          _formKey.currentState!.reset();
          _deliveryAreaController.clear();
          _completeAddressController.clear();
          _contactNoController.clear();
          _deliveryInstructionsController.clear();
          _latitudeController.clear();
          _longitudeController.clear();
          _nicknameController.clear();
        } else {
          // Parse error message from response
          String errorMessage = 'Failed to save address: ${response.statusCode}';
          try {
            final errorData = jsonDecode(response.body);
            if (errorData['message'] != null) {
              errorMessage = errorData['message'];
            } else if (errorData['errors'] != null) {
              // Handle validation errors
              final errors = errorData['errors'] as Map<String, dynamic>;
              errorMessage = errors.values.first.toString();
            }
          } catch (e) {
            print('Error parsing response: $e');
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      print('Exception: $e'); // Debug print
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipping Address'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add New Address',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Nickname
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Address Nickname',
                  hintText: 'e.g., Home, Office',
                  prefixIcon: Icon(Icons.label),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a nickname';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Delivery Area
              TextFormField(
                controller: _deliveryAreaController,
                decoration: const InputDecoration(
                  labelText: 'Delivery Area',
                  hintText: 'e.g., Butwal',
                  prefixIcon: Icon(Icons.location_city),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter delivery area';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Complete Address
              TextFormField(
                controller: _completeAddressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Complete Address',
                  hintText: 'e.g., Butwal-03, Jyotinagar',
                  prefixIcon: Icon(Icons.home),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter complete address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Contact Number
              TextFormField(
                controller: _contactNoController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  hintText: 'e.g., 9742906499',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact number';
                  }
                  if (value.length < 10) {
                    return 'Please enter a valid contact number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Delivery Instructions
              TextFormField(
                controller: _deliveryInstructionsController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Delivery Instructions',
                  hintText: 'e.g., Near Jyotinagar Chaupari',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter delivery instructions';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Latitude and Longitude
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        hintText: '28.2323232',
                        prefixIcon: Icon(Icons.my_location),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        hintText: '82.123434',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitAddress,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Save Address',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
