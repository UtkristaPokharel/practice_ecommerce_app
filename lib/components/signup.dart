import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../controller/theme_controller.dart';
import 'otp_verification.dart';
import '../services/auth_service.dart';

class Mysignup extends StatefulWidget {
  const Mysignup({super.key});

  @override
  State<Mysignup> createState() => _MysignupState();
}

class _MysignupState extends State<Mysignup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _signupUser() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final mobile = _mobileController.text.trim();
    final password = _passwordController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        mobile.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isLoading = true);

    const String url =
        'https://ecommerce.atithyahms.com/api/v2/ecommerce/customer/register';

    try {
      final deviceToken = await AuthService.getDeviceToken();
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'mobile_no': mobile,
          'password': password,
          'device_token': deviceToken ?? '',
        }),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      // Check for successful response with more flexible conditions
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 203) {
        // Check if status is true or success is true
        final isSuccess = data['status'] == true || data['success'] == true;

        if (isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Registration Successful! Please verify OTP sent to $mobile',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Navigate to OTP verification page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerification(
                mobileNumber: mobile,
                firstName: firstName,
                lastName: lastName,
              ),
            ),
          );
        } else {
          // API returned 200 but status/success is false
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Signup failed'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else if (response.statusCode == 409) {
        // 409 Conflict - User already exists
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message'] ??
                  'This mobile number is already registered. Please use a different number or login.',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        // Other non-success status codes
        String errorMessage;
        switch (response.statusCode) {
          case 400:
            errorMessage = 'Invalid input. Please check your details.';
            break;
          case 500:
            errorMessage = 'Server error. Please try again later.';
            break;
          default:
            errorMessage =
                data['message'] ?? 'Signup failed. Please try again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkNotifier,
      builder: (context, isDark, child) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/signup.png'),
              fit: BoxFit.cover,
              colorFilter: isDark
                  ? ColorFilter.mode(
                      Colors.black.withOpacity(0.6),
                      BlendMode.darken,
                    )
                  : null,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 35, top: 130),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(color: Colors.white, fontSize: 33),
                  ),
                ),
                SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 250),
                        Form(
                          key: _formKey,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 35),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _firstNameController,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    fillColor: isDark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade200,
                                    filled: true,
                                    hintText: 'First Name',
                                    hintStyle: TextStyle(
                                      color: isDark
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _lastNameController,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    fillColor: isDark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade200,
                                    filled: true,
                                    hintText: 'Last Name',
                                    hintStyle: TextStyle(
                                      color: isDark
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _mobileController,
                                  keyboardType: TextInputType.phone,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    fillColor: isDark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade200,
                                    filled: true,
                                    hintText: 'Mobile Number',
                                    hintStyle: TextStyle(
                                      color: isDark
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    fillColor: isDark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade100,
                                    filled: true,
                                    hintText: 'Password',
                                    hintStyle: TextStyle(
                                      color: isDark
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 27,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: const Color(0xff4c505b),
                                      child: _isLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                          : IconButton(
                                              color: Colors.white,
                                              onPressed: _signupUser,
                                              icon: const Icon(
                                                Icons.arrow_forward,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/login');
                                      },
                                      child: Text(
                                        'Sign In',
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          fontSize: 18,
                                          color: isDark
                                              ? Colors.white70
                                              : const Color(0xff4c505b),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Dark mode toggle button - placed last to be on top
                SafeArea(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Material(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(30),
                        child: IconButton(
                          onPressed: () {
                            isDarkNotifier.value = !isDarkNotifier.value;
                            print('Dark mode toggled: ${isDarkNotifier.value}');
                          },
                          icon: Icon(
                            isDark ? Icons.light_mode : Icons.dark_mode,
                            color: Colors.white,
                            size: 26,
                          ),
                          tooltip: isDark
                              ? 'Switch to Light Mode'
                              : 'Switch to Dark Mode',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
