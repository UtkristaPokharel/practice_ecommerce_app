import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../controller/profile_controller.dart';
import '../controller/theme_controller.dart';
import '../services/auth_service.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      print('Google User Details: ${googleUser.email}, ${googleUser.displayName}, ${googleUser.photoUrl}');
      print('Authentication Tokens: ID Token: ${googleAuth.idToken}');

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final deviceToken = await AuthService.getDeviceToken();

      if (!mounted) return;
      final Map<String, dynamic> requestData = {
        "first_name": firebaseUser.displayName?.split(' ').first ?? 'User',
        "last_name": (firebaseUser.displayName != null && firebaseUser.displayName!.split(' ').length > 1)
            ? firebaseUser.displayName!.split(' ').last
            : '',
        "mobile_no": "",
        "email": firebaseUser.email,
        "profile_image": firebaseUser.photoURL ?? "",
        "provider_id": firebaseUser.uid,
        "device_token": deviceToken ?? '',
      };

      // Send data to the API
      final response = await http.post(
        Uri.parse('https://ecommerce.atithyahms.com/api/v2/ecommerce/customer/google/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      print('API Response: ${response.statusCode} - ${response.body}');
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['data'] ?? data['user'];
        final apiToken = data['api_token'];

        if (userData != null) {
          final Map<String, dynamic> completeUserData = Map.from(userData);
          final dynamic existingImage = completeUserData['profile_image'];
          final bool hasImage =
              existingImage is String && existingImage.trim().isNotEmpty;
          final bool hasGooglePhoto =
              firebaseUser.photoURL != null && firebaseUser.photoURL!.isNotEmpty;
          if (!hasImage && hasGooglePhoto) {
            completeUserData['profile_image'] = firebaseUser.photoURL;
          }
          await ProfileController.setUserData(
            completeUserData,
            token: apiToken,
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signed in as ${firebaseUser.displayName}')),
        );

        print('Attempting to navigate to /home');
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        print('API Error: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('API Error: ${response.body}')),
        );
      }
    } catch (e) {
      print('Google Sign-In failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  Future<void> _loginUser() async {
    final username = _emailcontroller.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter all fields')));
      return;
    }

    const String url =
        'https://ecommerce.atithyahms.com/api/v2/ecommerce/customer/login';

    setState(() => _isLoading = true);

    try {
      final deviceToken = await AuthService.getDeviceToken();
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
          'device_token': deviceToken ?? '',
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;
      if ((response.statusCode == 200 || response.statusCode == 203) &&
          (data['status'] == true || data['success'] == true)) {
        final userData = data['data'] ?? data['user'];
        final userName = userData?['first_name'] ?? userData?['name'] ?? 'User';
        final apiToken = data['api_token'];

        if (userData != null) {
          final Map<String, dynamic> completeUserData = Map.from(userData);
          if (RegExp(r'^\d+$').hasMatch(username)) {
            completeUserData['mobile_no'] = username;
          }
          await ProfileController.setUserData(
            completeUserData,
            token: apiToken,
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Successful! Welcome $userName')),
        );

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Login failed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailcontroller.dispose();
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
              image: const AssetImage('assets/login.png'),
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
                    'Welcome\nBack',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 300),
                        Form(
                          key: _formKey,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 35),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _emailcontroller,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    fillColor: isDark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade200,
                                    filled: true,
                                    hintText: 'Enter your phone number',
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
                                const SizedBox(height: 30),
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
                                      'Sign In',
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
                                              onPressed: _loginUser,
                                              icon: const Icon(
                                                Icons.arrow_forward,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/signup');
                                      },
                                      child: Text(
                                        'Sign Up',
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          fontSize: 18,
                                          color: isDark
                                              ? Colors.white70
                                              : const Color(0xff4c505b),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/forgot-password',
                                        );
                                      },
                                      child: Text(
                                        'Forgot Password',
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
                                const SizedBox(height: 30),
                                // Divider with "OR" text
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: isDark
                                            ? Colors.white54
                                            : Colors.grey.shade600,
                                        thickness: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Text(
                                        'OR',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.grey.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: isDark
                                            ? Colors.white54
                                            : Colors.grey.shade600,
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // Google Sign In Button
                                OutlinedButton(
                                  onPressed: _signInWithGoogle,
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: isDark
                                        ? Colors.grey.shade800
                                        : Colors.white,
                                    side: BorderSide(
                                      color: isDark
                                          ? Colors.grey.shade600
                                          : Colors.grey.shade300,
                                      width: 1,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/google_logo.png',
                                        height: 24,
                                        width: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Sign in with Google',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
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
