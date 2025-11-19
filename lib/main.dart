import 'package:ecommerce_practice/pages/cart.dart';
import 'package:ecommerce_practice/pages/categories.dart';
import 'package:ecommerce_practice/components/login.dart';
import 'package:ecommerce_practice/components/signup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ecommerce_practice/home.dart';
import 'package:ecommerce_practice/pages/favourites.dart';
import 'package:ecommerce_practice/pages/profilepage.dart';
import 'package:ecommerce_practice/bottom_navbar.dart';
import 'package:ecommerce_practice/controller/navigation_controller.dart';
import 'package:ecommerce_practice/controller/theme_controller.dart';
import 'package:ecommerce_practice/profilepages/edit_profile.dart';
import 'package:ecommerce_practice/profilepages/shipping_address.dart';
import 'package:ecommerce_practice/profilepages/my_orders.dart';
import 'package:ecommerce_practice/profilepages/my_address.dart';
import 'package:ecommerce_practice/profilepages/password_reset.dart';
import 'package:ecommerce_practice/controller/profile_controller.dart';
import 'package:ecommerce_practice/components/forgot_password.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('Initializing Firebase...');
    await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully.');
  } catch (e) {
    print('Error during Firebase initialization: $e');
  }

  try {
    await ProfileController.loadUserData();
  } catch (e) {
    print('Warning: Could not load user data on startup: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  bool _checkedLogin = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _checkedLogin = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkNotifier,
      builder: (context, isDark, _) {
        final ThemeData themeData = ThemeData(
          brightness: isDark ? Brightness.dark : Brightness.light,
          useMaterial3: true,
          colorScheme: isDark
              ? const ColorScheme.dark(
                  primary: Color.fromARGB(255, 0, 149, 255),
                  secondary: Color.fromARGB(255, 25, 0, 255),
                  surface: Color.fromARGB(255, 1, 1, 1),
                  onPrimary: Colors.white,
                  onSecondary: Colors.white,
                )
              : const ColorScheme.light(
                  primary: Colors.blueAccent,
                  secondary: Color.fromARGB(255, 0, 30, 255),
                  surface: Colors.white,
                  onPrimary: Colors.white,
                  onSecondary: Colors.white,
                ),
        );

        if (!_checkedLogin) {
          // Show splash/loading while checking login
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeData,
          routes: {
            '/login': (context) => const MyLogin(),
            '/signup': (context) => const Mysignup(),
            '/home': (context) => const HomeWrapper(),
            '/edit-profile': (context) => const EditProfilePage(),
            '/shipping-address': (context) => const ShippingAddressPage(),
            '/my-orders': (context) => const MyOrdersPage(),
            '/my-address': (context) => const MyAddressPage(),
            '/password-reset': (context) => const PasswordResetPage(),
            '/forgot-password': (context) => const ForgotPasswordPage(),
          },
          home: _isLoggedIn ? const HomeWrapper() : const MyLogin(),
        );
      },
    );
  }
}

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  String searchQuery = '';
  int _selectedIndex = 0;

  void _handleSearchChanged(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });
  }

  void _onNavTapped(int index) {
    bottomNavIndex.value = index;
  }

  @override
  void initState() {
    super.initState();
    bottomNavIndex.addListener(() {
      if (mounted) {
        setState(() {
          _selectedIndex = bottomNavIndex.value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomePage(
            initialSearchQuery: searchQuery,
            onSearchChanged: _handleSearchChanged,
          ),
          const MyCategorie(),
          const FavouritesPage(),
          const CartPage(),
          const MyProfile(),
        ],
      ),
      bottomNavigationBar: BottomNavbar(
        index: _selectedIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}
